module AVCore
  module Metadata
    module Fields
      class TextField < Field
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
