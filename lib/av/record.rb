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

    def tind_id
      metadata.tind_id
    end

    def record_id
      metadata.record_id
    end

    def ucb_access?
      metadata.ucb_access?
    end

    def player_link_text
      metadata.player_link_text
    end

    def type_label
      @type_label ||= begin
        file_types = Set.new(tracks.map(&:file_type)).to_a.sort
        file_types = AV::Types::FileType.to_a if file_types.empty?

        file_types.map(&:label).join(' / ')
      end
    end

    def player_uri
      @player_uri ||= URI.join(AV::Config.avplayer_base_uri, "#{collection}/#{record_id}")
    end

    def display_uri
      metadata.display_uri
    end

    def description
      @description ||= begin
        desc_value = metadata.values.find { |v| v.tag == '520' }
        desc_value ? desc_value.lines.join(' ').gsub(/[[:space:]]+/, ' ').strip : ''
      end
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
