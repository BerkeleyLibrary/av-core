require 'av/constants'
require 'av/marc/subfield_groups'
require 'av/metadata/link_value'
require 'av/metadata/text_value'

module AV
  class Metadata
    class Field
      include Comparable
      include AV::Constants
      include AV::Util

      attr_reader :order, :label, :tag, :ind_1, :ind_2, :subfield_order, :subfields_separator

      # rubocop:disable Metrics/ParameterLists
      def initialize(order:, label:, tag:, ind_1: nil, ind_2: nil, subfield_order: nil, subfields_separator: nil)
        @order = order
        @label = label
        @tag = tag
        @ind_1 = ind_1
        @ind_2 = ind_2
        @subfield_order = subfield_order
        @subfields_separator = subfields_separator || ' '
      end
      # rubocop:enable Metrics/ParameterLists

      # @param marc_record [MARC::Record]
      # @return [Metadata::Fields::Value]
      def value_from(marc_record)
        all_subfield_values = all_subfield_groups(marc_record)
        return if all_subfield_values.empty?

        case tag
        when TAG_LINK_FIELD
          LinkValue.from_subfield_values(all_subfield_values, tag: tag, label: label, order: order)
        else
          TextValue.from_subfield_values(all_subfield_values, tag: tag, label: label, order: order, subfields_separator: subfields_separator)
        end
      end

      def value?(value)
        value && value.tag == tag && value.label == label && value.order == order
      end

      # @param other [Field] the Field to compare
      def <=>(other)
        return unless other
        return 0 if equal?(other)

        %i[order tag ind_1 ind_2 subfields_separator label].each do |attr|
          return nil unless other.respond_to?(attr)

          o = compare_values(send(attr), other.send(attr))
          return o if o != 0
        end

        compare_values(subfield_order&.join, other.subfield_order&.join)
      end

      # @param other [Field] the Reader to compare
      # @return [Boolean] true if `self` represents the same MARC tag/field/subfields as the specified `other`, false otherwise
      def same_field?(other)
        %i[tag ind_1 ind_2 subfields_separator subfield_order].all? do |attr|
          (other.respond_to?(attr) && send(attr) == other.send(attr))
        end
      end

      private

      def all_subfield_groups(marc_record)
        data_fields = marc_record.fields(tag).select { |f| indicators_match?(f) }
        data_fields.inject([]) do |all_groups, df|
          groups = AV::Marc::SubfieldGroups.from_data_field(df, subfield_order)
          groups.empty? ? all_groups : all_groups << groups
        end
      end

      def indicators_match?(data_field)
        return false if ind_1 && ind_1 != data_field.indicator1
        return false if ind_2 && ind_2 != data_field.indicator2

        true
      end

    end
  end
end
