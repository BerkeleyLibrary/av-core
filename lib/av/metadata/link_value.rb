require 'av/metadata/value'
require 'av/metadata/link'

module AV
  class Metadata
    class LinkValue < Value
      attr_reader :links

      def initialize(tag:, label:, links:, order:)
        super(tag: tag, label: label, order: order)
        @links = links || []
      end

      def to_s
        "#{label} (#{tag}): #{links && links.map(&:to_s).join(' ')}"
      end

      def any_link?(body: /.*/s, url: /.*/s)
        links.any? { |link| link.match?(body: body, url: url) }
      end

      class << self
        # @param all_subfield_values [Array<Hash<Symbol, String>>]
        def from_subfield_values(all_subfield_values, tag:, label:, order:)
          links = all_subfield_values.map do |vv|
            next unless (url = vv[:u]) && (body = body_from(vv))

            Link.new(body: body, url: url)
          end
          LinkValue.new(tag: tag, label: label, links: links, order: order)
        end

        private

        SUBFIELD_LINK_TEXT = :y
        SUBFIELD_PUBLIC_NOTE = :z
        SUBFIELD_MATERIALS_SPECD = :"3"

        def body_from(value_group)
          body = value_group[SUBFIELD_PUBLIC_NOTE] || value_group[SUBFIELD_LINK_TEXT]
          materials_specified = value_group[SUBFIELD_MATERIALS_SPECD]
          return body unless materials_specified
          return materials_specified unless body

          "#{materials_specified} #{body}"
        end
      end
    end
  end
end
