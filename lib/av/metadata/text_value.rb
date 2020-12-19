require 'av/metadata/value'

module AV
  class Metadata
    class TextValue < Value
      attr_reader :lines

      def initialize(tag:, label:, lines:, order:)
        super(tag: tag, label: label, order: order)
        @lines = lines || []
      end

      def to_s
        "#{label} (#{tag}): #{lines && lines.join('| ')}"
      end

      class << self
        # @param all_subfield_values [Array<Hash<Symbol, String>>]
        def from_subfield_values(all_subfield_values, tag:, label:, order:, subfields_separator:)
          lines = all_subfield_values.map { |vv| vv.values.join(subfields_separator) }
          TextValue.new(tag: tag, label: label, lines: lines, order: order)
        end
      end
    end
  end
end
