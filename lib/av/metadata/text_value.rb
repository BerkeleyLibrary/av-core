require 'av/metadata/value'

module AV
  class Metadata
    class TextValue < Value
      attr_reader :lines

      def initialize(tag:, label:, lines:)
        super(tag: tag, label: label)
        @lines = lines
      end

      def to_s
        "#{label} (#{tag}): #{lines && lines.join('| ')}"
      end

      def first
        lines && lines.first
      end

      class << self
        def from_subfield_values(all_subfield_values, tag:, label:, subfields_separator:)
          lines = []
          all_subfield_values.each do |subfield_values|
            subfield_values.each do |code_to_value|
              lines << code_to_value.values.join(subfields_separator)
            end
          end
          TextValue.new(tag: tag, label: label, lines: lines)
        end
      end
    end
  end
end
