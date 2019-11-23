module AVCore
  module Metadata
    module Fields
      class Field
        attr_reader :tag
        attr_reader :label

        def initialize(tag:, label:)
          @tag = tag
          @label = label
        end
      end
    end
  end
end
