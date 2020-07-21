module AV
  class Metadata
    class Link
      include Comparable

      attr_reader :body
      attr_reader :url

      def initialize(body:, url:)
        @body = body
        @url = url
      end

      def to_s
        "[#{body}](#{url})"
      end

      def <=>(other)
        return unless other
        return 0 if equal?(other)
        return unless other.is_a?(Link)

        to_s <=> other.to_s
      end
    end
  end
end
