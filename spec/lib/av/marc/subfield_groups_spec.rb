require 'spec_helper'

module AV
  module Marc
    describe SubfieldGroups do
      describe :to_a do
        it 'transposes the values' do
          sv = SubfieldGroups.new(
            a: [1, 3, 5],
            b: [2, 4, 6],
            c: [7, 9]
          )
          expected = [
            { a: 1, b: 2, c: 7 },
            { a: 3, b: 4, c: 9 },
            { a: 5, b: 6 }
          ]
          expect(sv.to_a).to eq(expected)
        end
      end

      describe :ordered_by do
        it 'reorders the values' do
          sv1 = SubfieldGroups.new(
            a: [1, 3, 5],
            b: [2, 4, 6],
            c: [7, 9]
          )
          sv2 = sv1.ordered_by(%i[c b a])
          expected = [
            { c: 7, b: 2, a: 1 },
            { c: 9, b: 4, a: 3 },
            { b: 6, a: 5 }
          ]
          sv2.to_a.each_with_index do |h_actual, i|
            h_expected = expected[i]
            expect(h_actual).to eq(h_expected)

            key_order_expected = h_expected.keys.to_a
            key_order_actual = h_actual.keys.to_a
            expect(key_order_actual).to eq(key_order_expected)
          end
        end
      end
    end
  end
end
