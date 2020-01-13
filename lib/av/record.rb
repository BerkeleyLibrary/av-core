require 'av/track'
require 'av/metadata'
require 'av/metadata/source'

require 'forwardable'

module AV
  class Record
    attr_reader :tracks, :metadata

    # TODO: introduce collections, somehow
    def initialize(metadata:, tracks:)
      @tracks = tracks.sort
      @metadata = metadata
    end

    def title
      metadata.title
    end

    def bib_number
      metadata.bib_number
    end

    class << self
      def from_metadata(record_id:, metadata_source:)
        metadata = Metadata.for_record(record_id: record_id, source: metadata_source)
        Record.new(
          metadata: metadata,
          tracks: Track.tracks_from(metadata.marc_record)
        )
      end
    end
  end
end
