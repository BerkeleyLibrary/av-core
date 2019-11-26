module AVCore
  module Metadata
    module Fields
      class LinkField < Field
        attr_reader :links

        def initialize(tag:, label:, links:)
          super(tag: tag, label: label)
          @links = links
        end

        def to_s
          "#{label} (#{tag}): #{links.map(&:to_s).join(' ')}"
        end

        class << self
          def from_subfield_values(all_subfield_values, tag:, label:)
            links = []
            all_subfield_values.each do |subfield_values|
              subfield_values.each do |value_group|
                next unless value_group.key?(:y) && value_group.key?(:u)

                links << Link.new(body: value_group[:y], url: value_group[:u])
              end
            end
            LinkField.new(tag: tag, label: label, links: links)
          end
        end
      end
    end
  end
end
