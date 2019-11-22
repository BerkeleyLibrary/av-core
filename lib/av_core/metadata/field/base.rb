module AVCore
  module Metadata
    module Field
      class Base
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
