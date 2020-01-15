require 'av/track'
require 'av/metadata'
require 'av/metadata/source'

module AV
  class Record
    attr_reader :collection, :tracks, :metadata

    def initialize(collection:, tracks:, metadata:)
      @collection = collection
      @tracks = tracks.sort
      @metadata = metadata
    end

    def title
      metadata.title
    end

    def bib_number
      metadata.bib_number
    end

    def player_uri
      @player_uri ||= URI.join(AV::Config.avplayer_base_uri, "#{collection}/#{bib_number}")
    end

    def description
      @description ||= begin
        desc_value = metadata.values.find { |v| v.tag == '520' }
        desc_value ? desc_value.lines.join(' ').gsub(/[[:space:]]+/, ' ').strip : ''
      end
    end

    class << self
      def from_metadata(collection:, record_id:)
        metadata = Metadata.for_record(record_id: record_id)
        Record.new(
          collection: collection,
          metadata: metadata,
          tracks: Track.tracks_from(metadata.marc_record)
        )
      end
    end
  end
end
