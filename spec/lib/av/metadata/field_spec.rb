require 'spec_helper'
require 'marc'

module AV
  class Metadata
    describe Field do
      attr_reader :marc_record

      before(:all) do
        @marc_record = MARC::XMLReader.new('spec/data/record-(pacradio)01469.xml').first
      end

      describe :<=> do
        it 'treats fields that differ only in subfield order as different' do
          args1 = { order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c] }
          args2 = args1.merge(subfield_order: %i[c n d a])
          ff1 = Field.new(args1)
          ff2 = Field.new(args2)
          expect(ff1 < ff2).to be_truthy
          expect(ff2 > ff1).to be_truthy
        end

        it 'returns nil for nil' do
          field = Field.new(order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c])
          expect(field <=> nil).to be_nil
        end

        it 'returns nil for things that are not Fields' do
          field = Field.new(order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c])
          expect(field <=> field.to_s).to be_nil
        end
      end
    end
  end
end
