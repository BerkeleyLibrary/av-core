require 'av/constants'
require 'av/types/duration'
require 'av/types/file_type'
require 'av/marc/util'
require 'marc'

module AV
  class Track
    include Comparable
    include AV::Constants
    include AV::Util

    attr_reader :sort_order, :title, :path, :duration, :file_type

    def initialize(sort_order:, path:, title: nil, duration: nil)
      @sort_order = sort_order
      @title = title
      @path = path
      @duration = duration_or_nil(duration)
      @file_type = AV::Types::FileType.for_path(path)
    end

    def <=>(other)
      return 0 if equal?(other)
      return unless other

      %i[sort_order title duration path].each do |attr|
        return nil unless other.respond_to?(attr)

        o = compare_values(send(attr), other.send(attr))
        return o if o && o != 0
      end

      0
    end

    def to_s
      ''.tap do |s|
        s << "#{sort_order}: " if sort_order
        s << path
        s << " #{title.inspect}" if title
        s << " (#{duration})" if duration
      end
    end

    def inspect
      "\#<#{self.class.name} #{self}>"
    end

    # @return [Array<MARC::Subfield>]
    def to_marc_subfields
      [].tap do |subfields|
        subfields << MARC::Subfield.new(SUBFIELD_CODE_DURATION, duration.to_s) if duration
        subfields << MARC::Subfield.new(SUBFIELD_CODE_TITLE, title) if title
        subfields << MARC::Subfield.new(SUBFIELD_CODE_PATH, path)
      end
    end

    private

    def duration_or_nil(duration)
      return duration if duration.is_a?(AV::Types::Duration)

      AV::Types::Duration.from_string(duration)
    end

    class << self
      include AV::Constants
      include AV::Util

      TRACKS_FIELD = AV::Metadata::Fields::TRACKS
      LABELS = {
        SUBFIELD_CODE_DURATION => 'duration',
        SUBFIELD_CODE_TITLE => 'title',
        SUBFIELD_CODE_PATH => 'path'
      }.freeze

      # Note that if multiple tracks are encoded in the same 998 field, the
      # subfields **must** be in the order :a, :t, :g (duration, title, path),
      # as documented in {https://docs.google.com/document/d/1gRWsaSoerSvadNlYR-zbYOjgj0geLxV41bBC0rm5nHE/edit
      # "How to add media to the AV System"}.
      #
      # This is **not** the same as the display order set in {AV::Metadata::Fields::TRACKS}.
      #
      # @param marc_record [MARC::Record] the MARC record
      # @param collection [String] the collection
      def tracks_from(marc_record, collection:)
        track_fields_from(marc_record).each_with_object([]) do |df, tracks|
          if single_track?(df)
            group = df.subfields.map { |sf| [sf.code.to_sym, sf.value] }.to_h
            tracks << from_group(group, collection: collection, sort_order: tracks.size)
          else
            add_multiple_tracks(df, tracks, collection)
          end
        end
      end

      private

      def single_track?(df)
        df.subfields.map { |sf| sf.code.to_sym }.count(SUBFIELD_CODE_PATH) == 1
      end

      def track_fields_from(marc_record)
        marc_record.fields.select { |df| df.tag == TRACKS_FIELD.tag }
      end

      def add_multiple_tracks(df, tracks, collection)
        group = nil
        df.subfields.each do |sf|
          (group ||= {})[sf.code.to_sym] = sf.value
          next unless sf.code.to_sym == SUBFIELD_CODE_PATH

          tracks << from_group(group, collection: collection, sort_order: tracks.size)
          group = nil
        end
      end

      def from_group(group, collection:, sort_order:)
        title = tidy_value(group[SUBFIELD_CODE_TITLE])
        path = tidy_value(group[SUBFIELD_CODE_PATH])
        duration = tidy_value(group[SUBFIELD_CODE_DURATION])
        Track.new(
          sort_order: sort_order,
          title: title,
          path: "#{collection}/#{path}",
          duration: duration
        )
      end

    end
  end
end
