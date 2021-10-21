require 'marc'
require 'av/util'

module AV
  module Marc
    module Util
      include AV::Util

      # Extracts the subfield values from the specifed MARC data field and
      # returns the groups of related subfield values in order as they
      # appear. For instance, for the following data field:
      #
      # ```
      # 505  00$tQuatrain II$g(16:35) --$tWater ways$g(1:57) --$tWaves$g(10:49).
      # ```
      #
      # this method would return:
      #
      # ```
      # [
      #   {t: 'Quatrain II', g: '(16:35)'},
      #   {t: 'Water ways', g: '(01:57)'},
      #   {t: 'Waves', g: '(10:49)'}
      # ]
      # ```
      #
      # If an order is provided, each group will be reordered according to
      # that order. E.g., given the order `[:g, :t]`, the above would be
      # returned instead as:
      #
      # ```
      # [
      #   {g: '(16:35)', t: 'Quatrain II'},
      #   {g: '(01:57)', t: 'Water ways'},
      #   {g: '(10:49)', t: 'Waves'},
      # ]
      # ```
      #
      # @param data_field [MARC::DataField] the data field
      # @param order [Array<Symbol>, nil] the order of subfield codes
      # @return [Array<Hash<Symbol, String>>] the grouped values
      def group_subfield_values(data_field, order: nil) # TODO: do we still need this?
        grouped_subfields = group_subfields(data_field.subfields, order: order)
        grouped_subfields.each_with_object([]) do |subfield_group, value_groups|
          value_group = subfield_group.transform_values { |sf| tidy_value(sf.value) }
          value_groups << value_group
        end
      end

      # Extracts the subfieldsfrom the specifed MARC data field and
      # returns the groups of related subfieldsin order as they
      # appear. For instance, for the following data field:
      #
      # ```
      # 505  00$tQuatrain II$g(16:35) --$tWater ways$g(1:57) --$tWaves$g(10:49).
      # ```
      #
      # this method would return:
      #
      # ```
      # [
      #   {t: #<Subfield @code='t', @value='Quatrain II'>, g: #<Subfield @code='g', @value='(16:35)'>},
      #   {t: #<Subfield @code='t', @value='Water ways'>, g: #<Subfield @code='g', @value='(01:57)'>},
      #   {t: #<Subfield @code='t', @value='Waves'>, g: #<Subfield @code='g', @value='(10:49)'>}
      # ]
      # ```
      #
      # If an order is provided, each group will be reordered according to
      # that order. E.g., given the order `[:g, :t]`, the above would be
      # returned instead as:
      #
      # ```
      # [
      #   {g: #<Subfield @code='g', @value='(16:35)'>, t: #<Subfield @code='t', @value='Quatrain II'>},
      #   {g: #<Subfield @code='g', @value='(01:57)'>, t: #<Subfield @code='t', @value='Water ways'>},
      #   {g: #<Subfield @code='g', @value='(10:49)'>, t: #<Subfield @code='t', @value='Waves'>},
      # ]
      # ```
      #
      # @param data_field [MARC::DataField] the data field
      # @param order [Array<Symbol>, nil] the order of subfield codes
      # @return [Array<Hash<Symbol, String>>] the grouped values
      def group_subfields(subfields, order: nil)
        by_code = subfields_by_code(subfields)
        order = by_code.keys if order.nil? || order.empty?
        group_by_code(by_code, order)
      end

      private

      def subfields_by_code(subfields)
        subfields.each_with_object({}) do |sf, h|
          (h[sf.code.to_sym] ||= []) << sf
        end
      end

      def group_by_code(subfields_by_code, order)
        order.each_with_object([]) do |code, groups|
          csym = code.to_sym
          next unless (subfields = subfields_by_code[csym])

          subfields.each_with_index { |v, i| (groups[i] ||= {})[csym] = v }
        end
      end

      class << self
        include AV::Marc::Util
      end
    end
  end
end
