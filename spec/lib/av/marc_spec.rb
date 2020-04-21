require 'spec_helper'

module AV
  describe Marc do
    describe :from_xml do
      it 'returns a single record' do
        marc_xml = File.read('spec/data/search-1993.xml')
        record = Marc.from_xml(marc_xml)
        expect(record).to be_a(MARC::Record)
      end
    end

    describe :all_from_xml do
      it 'returns multiple records' do
        marc_xml = File.read('spec/data/search-1993.xml')
        reader = Marc.all_from_xml(marc_xml)
        records = reader.to_a
        expect(records.size).to eq(2)
        records.each do |record|
          expect(record).to be_a(MARC::Record)
        end
      end
    end
  end
end
