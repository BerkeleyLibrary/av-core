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
      end
    end
  end
end
