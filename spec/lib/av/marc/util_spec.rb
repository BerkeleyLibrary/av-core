require 'spec_helper'
require 'marc'

module AV
  module Marc
    module Util
      describe :grouped_subfield_values do
        let(:df) { MARC::DataField.new('999') }
        let(:original_groups) do
          [
            { b: '2', a: '1', c: '7' },
            { b: '4', a: '3', c: '9' },
            { b: '6', a: '5', c: '10' }
          ]
        end

        let(:order) { %i[c b a] }
        let(:ordered_groups) do
          [
            { c: '7', b: '2', a: '1' },
            { c: '9', b: '4', a: '3' },
            { c: '10', b: '6', a: '5' }
          ]
        end

        describe 'pre-grouped subfields' do
          before(:each) do
            original_groups.each do |g|
              g.each { |c, v| df.subfields << MARC::Subfield.new(c, v) }
            end
          end

          it 'returns the groups' do
            groups = Util.group_subfield_values(df)
            expect(groups).to eq(original_groups)
          end

          it 'reorders the groups' do
            reordered = Util.group_subfield_values(df, order: order)
            # Hash equality doesn't check order, so we do it by hand
            reordered.each_with_index do |actual, i|
              expected = ordered_groups[i]
              expect(actual.keys).to eq(expected.keys), "#{i}: expected: #{expected}, got: #{actual}"
              expect(actual.values).to eq(expected.values), "#{i}: expected: #{expected}, got: #{actual}"
            end
          end
        end

        describe 'pre-grouped by code' do
          before(:each) do
            {
              b: %w[2 4 6],
              a: %w[1 3 5],
              c: %w[7 9 10]
            }.each do |c, vv|
              vv.each { |v| df.subfields << MARC::Subfield.new(c, v) }
            end
          end

          it 'groups the values' do
            groups = Util.group_subfield_values(df)
            expect(groups).to eq(original_groups)
          end

          it 'reorders the groups' do
            reordered = Util.group_subfield_values(df, order: order)
            # Hash equality doesn't check order, so we do it by hand
            reordered.each_with_index do |actual, i|
              expected = ordered_groups[i]
              expect(actual.keys).to eq(expected.keys), "#{i}: expected: #{expected}, got: #{actual}"
              expect(actual.values).to eq(expected.values), "#{i}: expected: #{expected}, got: #{actual}"
            end
          end
        end

        describe 'inconsistent order' do
          let(:inconsistent_groups) do
            [
              { a: '1', b: '2', c: '7' },
              { b: '4', a: '3', c: '9' },
              { c: '10', a: '5', b: '6' }
            ]
          end

          before(:each) do
            inconsistent_groups.each do |g|
              g.each { |c, v| df.subfields << MARC::Subfield.new(c, v) }
            end
          end

          it 'groups the values' do
            groups = Util.group_subfield_values(df)
            expect(groups).to eq(inconsistent_groups)
          end

          it 'reorders the groups' do
            reordered = Util.group_subfield_values(df, order: order)
            # Hash equality doesn't check order, so we do it by hand
            reordered.each_with_index do |actual, i|
              expected = ordered_groups[i]
              expect(actual.keys).to eq(expected.keys), "#{i}: expected: #{expected}, got: #{actual}"
              expect(actual.values).to eq(expected.values), "#{i}: expected: #{expected}, got: #{actual}"
            end
          end
        end

        describe 'ragged groups' do
          let(:ragged_groups) do
            [{ a: '1' }, { b: '2' }, { c: '7' }, { b: '4' }, { c: '9' }, { a: '5' }, { b: '6' }]
          end
          let(:ragged_reordered) do
            [
              { c: '7', b: '2', a: '1' },
              { c: '9', b: '4', a: '5' },
              { b: '6' }
            ]
          end

          before(:each) do
            ragged_groups.each do |g|
              g.each { |c, v| df.subfields << MARC::Subfield.new(c, v) }
            end
          end

          it 'groups the values' do
            expected = [
              { a: '1', b: '2', c: '7' },
              { a: '5', b: '4', c: '9' },
              { b: '6' }
            ]
            groups = Util.group_subfield_values(df)
            expect(groups).to eq(expected)
          end

          it 'reorders the values' do
            reordered = Util.group_subfield_values(df, order: order)
            # Hash equality doesn't check order, so we do it by hand
            reordered.each_with_index do |actual, i|
              expected = ragged_reordered[i]
              expect(actual.keys).to eq(expected.keys), "#{i}: expected: #{expected}, got: #{actual}"
              expect(actual.values).to eq(expected.values), "#{i}: expected: #{expected}, got: #{actual}"
            end
          end
        end
      end
    end
  end
end
