require 'marc'
require 'av/util'

module AV
  module Marc
    module Util
      class << self
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
        def group_subfield_values(data_field, order: nil)
          by_code = values_by_code(data_field.subfields)
          group_values_by_code(by_code, order: order)
        end

        private

        def values_by_code(subfields)
          {}.tap do |h|
            subfields.each do |sf|
              (h[sf.code.to_sym] ||= []) << tidy_value(sf.value)
            end
          end
        end

        def group_values_by_code(values_by_code, order: nil)
          [].tap do |groups|
            (order || values_by_code.keys).each do |code|
              next unless (values = values_by_code[code])

              values.each_with_index { |v, i| (groups[i] ||= {})[code] = v }
            end
          end
        end
      end
    end
  end
end
