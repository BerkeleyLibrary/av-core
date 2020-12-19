require 'spec_helper'
require 'marc'

module AV
  module Marc
    module Util
      describe :group_subfield_values do
        attr_reader :df
        attr_reader :original_groups

        before(:each) do
          @df = MARC::DataField.new('999')
          @original_groups = [
            { b: '2', a: '1', c: '7' },
            { b: '4', a: '3', c: '9' },
            { b: '6', a: '5', c: '10' }
          ]
        end

        describe 'pre-grouped subfields' do
          before(:each) do
            original_groups.each do |g|
              g.each { |c, v| df.subfields << MARC::Subfield.new(c, v) }
            end
          end

          describe :to_a do
            it 'returns the groups' do
              groups = Util.group_subfield_values(df)
              expect(groups.to_a).to eq(original_groups)
              groups.to_a.each_with_index do |actual, i|
                expect(actual.keys).to eq(original_groups[i].keys)
                expect(actual.values).to eq(original_groups[i].values)
              end
            end
          end

          describe :ordered_by do
            it 'reorders the groups' do
              expected = [
                { c: '7', b: '2', a: '1' },
                { c: '9', b: '4', a: '3' },
                { c: '10', b: '6', a: '5' }
              ]
              reordered = Util.group_subfield_values(df, order: %i[c b a])
              reordered.to_a.each_with_index do |actual, i|
                expect(actual.keys).to eq(expected[i].keys)
                expect(actual.values).to eq(expected[i].values)
              end
            end
          end
        end

        describe 'grouped by code' do
          before(:each) do
            all_codes = original_groups.flat_map(&:keys).uniq
            all_codes.each do |c|
              original_groups.each do |g|
                next unless (v = g[c])

                df.subfields << MARC::Subfield.new(c, v)
              end
            end
          end

          describe :to_a do
            it 'groups the values' do
              groups = Util.group_subfield_values(df)
              expect(groups.to_a).to eq(original_groups)
            end
          end

          describe :ordered_by do
            it 'reorders the groups' do
              expected = [
                { c: '7', b: '2', a: '1' },
                { c: '9', b: '4', a: '3' },
                { c: '10', b: '6', a: '5' }
              ]
              reordered = Util.group_subfield_values(df, order: %i[c b a])
              expect(reordered.to_a).to eq(expected), "expected: #{expected}\n     got: #{reordered}"
              # Hash equality doesn't check order, so we do it by hand
              reordered.to_a.each_with_index do |actual, i|
                expect(actual.keys).to eq(expected[i].keys), "#{i}: expected: #{expected[i]}\n       got: #{actual}"
                expect(actual.values).to eq(expected[i].values), "#{i}: expected: #{expected[i]}\n       got: #{actual}"
              end
            end
          end
        end
      end
    end
  end
end
