module AvPlayer
  module Core
    class Record
      attr_reader :bib_number, :tracks, :metadata_source

      def initialize(bib_number:, tracks:, metadata_source: Metadata::Source::MILLENNIUM)
        @bib_number = bib_number
        @tracks = tracks.sort
        @metadata_source = metadata_source
      end
    end
  end
end
