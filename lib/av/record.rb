require 'berkeley_library/util'

require 'av/track'
require 'av/metadata'
require 'av/metadata/source'

module AV
  class Record
    include BerkeleyLibrary::Util

    attr_reader :collection, :tracks, :metadata

    # TODO: stop passing in track list & just get it from metadata & collection
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

    def tind_id
      metadata.tind_id
    end

    def record_id
      metadata.record_id
    end

    def calnet_or_ip?
      metadata.calnet_or_ip?
    end

    def calnet_only?
      metadata.calnet_only?
    end

    def type_label
      @type_label ||= begin
        file_types = Set.new(tracks.map(&:file_type)).to_a.sort
        file_types = AV::Types::FileType.to_a if file_types.empty?

        file_types.map(&:label).join(' / ')
      end
    end

    def player_uri
      @player_uri ||= URIs.append(AV::Config.avplayer_base_uri, collection, record_id)
    end

    def display_uri
      metadata.display_uri
    end

    def description
      metadata.description
    end

    class << self
      # Loads the metadata for the specified record and creates a record object from it.
      #
      # Note that for TIND records the record ID is *not* the TIND internal ID
      # (MARC field 001) but rather the ID assigned by the UC Berkeley Library
      # (MARC field 035).
      #
      # @param collection [String] The collection name (Wowza application id).
      # @param record_id [String] The record ID.
      def from_metadata(collection:, record_id:)
        metadata = Metadata.for_record(record_id: record_id)
        Record.new(
          collection: collection,
          metadata: metadata,
          tracks: Track.tracks_from(metadata.marc_record, collection: collection)
        )
      end
    end
  end
end
