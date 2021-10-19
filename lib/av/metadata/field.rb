require 'av/constants'
require 'av/marc/util'
require 'av/metadata/value'
require 'marc/spec'

module AV
  class Metadata
    class Field
      include AV::Marc::Util
      include Comparable

      # ------------------------------------------------------------
      # Constants

      SPEC_TAG_RE = /^([0-9a-z.]{3})/

      # ------------------------------------------------------------
      # Accessors

      attr_reader :order, :label, :tag, :spec, :query, :subfields_separator, :subfield_order

      # ------------------------------------------------------------
      # Initializer

      # rubocop:disable Metrics/ParameterLists
      def initialize(order:, label:, spec:, tag: nil, subfields_separator: ' ', subfield_order: [])
        @order = order
        @label = label
        @spec = spec
        @query = MARC::Spec.parse_query(spec)
        @tag = tag || query.tag_str
        @subfields_separator = subfields_separator
        @subfield_order = subfield_order
      end
      # rubocop:enable Metrics/ParameterLists

      # ------------------------------------------------------------
      # Public methods

      def value_from(marc_record)
        results = MARC::Spec.execute_query(query, marc_record)
        subfield_groups = subfield_groups_from_result(results)
        Value.value_for(self, subfield_groups)
      end

      def same_metadata?(other)
        raise ArgumentError, "Not a #{class_name(self)}: #{other}" unless other.is_a?(Field)

        %i[tag query subfields_separator subfield_order].all? do |attr|
          (other.respond_to?(attr) && send(attr) == other.send(attr))
        end
      end

      # ------------------------------
      # Object

      def to_s
        "#{order}. #{query} #{label.inspect}".tap do |str|
          str << " #{subfields_separator.inspect}" unless subfields_separator == ' '
          str << " $#{subfield_order.join('$')}" unless subfield_order.empty?
        end
      end

      def inspect
        "#<#{class_name(self)} #{self}>"
      end

      # ------------------------------
      # Comparable

      def <=>(other)
        return unless other.is_a?(Field)
        return 0 if equal?(other)

        %i[order tag query subfields_separator label].each do |attr|
          o = compare_values(send(attr), other.send(attr))
          return o if o != 0
        end

        compare_values(subfield_order&.join, other.subfield_order&.join)
      end

      # ------------------------------------------------------------
      # Private

      private

      def subfield_groups_from_result(marc_result)
        return marc_result.map { |r| subfield_groups_from_result(r) }.flatten if marc_result.is_a?(Array)

        subfields = subfields_from_result(marc_result)
        group_subfields(subfields, order: subfield_order)
      end

      def subfields_from_result(marc_result)
        return [marc_result] if marc_result.is_a?(MARC::Subfield)
        return [] unless marc_result.respond_to?(:subfields)

        marc_result.subfields
      end

    end
  end
end
