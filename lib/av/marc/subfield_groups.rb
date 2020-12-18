require 'marc'
require 'av/util'

module AV
  module Marc
    # Encapsulates a set of repeated subfields. E.g. for the following
    # data field:
    #
    # ```
    # 505  00$tQuatrain II$g(16:35) --$tWater ways$g(1:57) --$tWaves$g(10:49).
    # ```
    #
    # each pair of `$t` and `$g` values would be grouped together.
    class SubfieldGroups
      include Enumerable

      attr_reader :values_by_code

      # @param values_by_code [{String,Symbol => Array<String>}] the subfield values,
      #   organized by code, with the list of values for each code
      def initialize(values_by_code)
        @values_by_code = values_by_code
      end

      class << self
        include AV::Util

        # Extracts the subfield values from the specifed MARC data field.
        # @param data_field [MARC::DataField] the data field
        # @param subfield_order [Array<Symbol>] the order of subfield codes
        # @return [SubfieldGroups] the grouped values
        def from_data_field(data_field, subfield_order = nil)
          by_code = {}.tap do |h1|
            data_field.subfields.each do |sf|
              (h1[sf.code.to_sym] ||= []) << tidy_value(sf.value)
            end
          end
          SubfieldGroups.new(by_code).ordered_by(subfield_order)
        end
      end

      # Returns the groups of related subfield values in order as they
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
      #   {t: 'Water ways', g: '(1:57)'},
      #   {t: 'Waves', g: '(10:49)'}
      # ]
      # ```
      #
      # @return [Array<Hash<Symbol, String>>] The grouped subfield values
      def to_a
        @as_array ||= [].tap do |vv|
          values_by_code.each do |code, values|
            values.each_with_index { |v, i| (vv[i] ||= {})[code] = v } if values
          end
        end
      end

      # Iterates over the array of hashes returned by {SubfieldGroups#to_a}
      # @see #to_a
      # @yield [Hash<Symbol, String>] a map from subfield code to value
      def each(&block)
        to_a.each(&block)
      end

      def empty?
        to_a.empty?
      end

      # Returns a {SubfieldValues} object with the subfields ordered
      # as specified. Note that any
      #
      # @param subfield_order [Array<Symbol>] the order of subfield codes.
      #   Note that any subfields not included in the order will be dropped.
      # @return [SubfieldGroups] the reordered values
      def ordered_by(subfield_order)
        return self unless subfield_order

        by_code_ordered = subfield_order.map { |code| [code, values_by_code[code]] }.to_h
        SubfieldGroups.new(by_code_ordered)
      end

    end
  end
end
