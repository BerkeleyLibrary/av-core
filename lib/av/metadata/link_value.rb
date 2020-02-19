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

      class << self
        def from_subfield_values(all_subfield_values, tag:, label:, order:)
          links = []
          all_subfield_values.each do |subfield_values|
            subfield_values.each do |value_group|
              body = value_group[:z] || value_group[:y]
              url = value_group[:u]
              next unless body && url

              links << Link.new(body: body, url: url)
            end
          end
          LinkValue.new(tag: tag, label: label, links: links, order: order)
        end
      end
    end
  end
end
