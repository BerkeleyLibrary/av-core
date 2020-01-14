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
      URI.join(AV::Config.avplayer_base_uri, "#{collection}/#{bib_number}")
    end

    class << self
      def from_metadata(collection:, record_id:, metadata_source:)
        metadata = Metadata.for_record(record_id: record_id, source: metadata_source)
        Record.new(
          collection: collection,
          metadata: metadata,
          tracks: Track.tracks_from(metadata.marc_record)
        )
      end
    end
  end
end
