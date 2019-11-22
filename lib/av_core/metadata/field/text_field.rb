module AVCore
  module Metadata
    module Field
      class TextField < Base
        attr_reader :lines

        def initialize(tag:, label:, lines:)
          super(tag: tag, label: label)
          @lines = lines
        end

        def to_s
          "#{label} (#{tag}): #{lines.join('| ')}"
        end
      end
    end
  end
end
