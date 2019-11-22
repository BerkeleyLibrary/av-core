module AVCore
  module Metadata
    module Field
      class LinkField < Base
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
