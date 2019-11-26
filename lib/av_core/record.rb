require 'av_core/metadata'

module AVCore
  class Record
    attr_reader :bib_number, :tracks, :metadata_source, :metadata_fields

    def initialize(bib_number:, tracks:, metadata_source:, metadata_fields:)
      @bib_number = bib_number
      @tracks = tracks.sort
      @metadata_source = metadata_source
      @metadata_fields = metadata_fields
    end

    class << self
      def from_metadata(record_id:, metadata_source:)
        marc_record = metadata_source.record_for(record_id)
        Record.new(
          bib_number: bib_number_for(record_id: record_id, metadata_source: metadata_source, marc_record: marc_record),
          tracks: Track.tracks_from(marc_record),
          metadata_source: metadata_source,
          metadata_fields: Metadata::Fields.fields_from(marc_record)
        )
      end

      private

      def bib_number_for(record_id:, metadata_source:, marc_record:)
        # noinspection RubyResolve
        return record_id if metadata_source == Metadata::Source::MILLENNIUM

        marc_record.each_by_tag('901') do |data_field|
          subfield_m = data_field.find { |sf| sf.code = 'm' }
          return subfield_m.value if subfield_m
        end
        nil
      end
    end
  end
end
