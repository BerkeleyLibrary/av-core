require 'uri'

module AV
  module Player
    class << self
      def avplayer_host
        # TODO: make this configurable
        'avplayer.lib.berkeley.edu'
      end

      # Generates a link to the new AV player page for a specific record.
      #
      # @param bib_number [String] the Millennium bib number
      # @param collection [String] the Wowza collection
      # @param paths [String, Array<String>] the path or paths to the audio files
      # @return [URI] the URI to the player page
      def link_to(bib_number:, collection:, paths:)
        paths = ensure_paths(paths)
        URI::HTTPS.build(
          host: avplayer_host,
          path: "/#{collection}/#{paths.join(';')}/show",
          query: URI.encode_www_form(record_id: "millennium:#{bib_number}")
        )
      end

      private

      def ensure_paths(paths)
        raise 'paths must be specified' unless paths
        return paths if paths.respond_to?(:join)

        [paths]
      end
    end
  end
end
