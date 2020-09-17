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

      attr_reader :by_code

      def initialize(by_code)
        @by_code = by_code
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
      def by_index
        @by_index ||= [].tap do |vv|
          by_code.each do |code, values|
            next unless values

            values.each_with_index do |v, i|
              vv[i] ||= {}
              vv[i][code] = v
            end
          end
        end
      end

      # Iterates over the array of hashes returned by {SubfieldGroups#by_index}
      # @see #by_index
      # @yield [Hash<Symbol, String>] a map from subfield code to value
      def each(&block)
        by_index.each(&block)
      end

      def empty?
        by_index.empty?
      end

      # Returns a {SubfieldValues} object with the subfields ordered
      # as specified.
      #
      # @param subfield_order [Array<Symbol>] the order of subfield codes
      # @return [SubfieldGroups] the reordered values
      def ordered_by(subfield_order)
        return self unless subfield_order

        by_code_ordered = {}
        subfield_order.each do |code|
          by_code_ordered[code] = by_code[code]
        end
        SubfieldGroups.new(by_code_ordered)
      end

      class << self
        include AV::Util

        # Extracts the subfield values from the specifed MARC data field.
        # @param data_field [MARC::DataField] the data field
        # @param subfield_order [Array<Symbol>] the order of subfield codes
        # @return [SubfieldGroups] the grouped values
        def from_data_field(data_field, subfield_order = nil)
          by_code = data_field.subfields.inject({}) do |h, sf|
            h.tap do |h1|
              code = sf.code.to_sym
              h1[code] ||= []
              h1[code] << tidy_value(sf.value)
            end
          end
          SubfieldGroups.new(by_code).ordered_by(subfield_order)
        end
      end
    end
  end
end
