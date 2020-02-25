module AV
  class Metadata
    class Value
      include Comparable
      include AV::Util

      attr_reader :tag
      attr_reader :label
      attr_reader :order

      def initialize(tag:, label:, order:)
        @tag = tag
        @label = label
        @order = order
      end

      # @param other [Value] the Value to compare
      def <=>(other)
        return unless other
        return 0 if equal?(other)

        %i[order tag label].each do |attr|
          return nil unless other.respond_to?(attr)

          o = compare_values(send(attr), other.send(attr))
          return o if o && o != 0
        end

        to_s <=> other.to_s
      end
    end
  end
end
