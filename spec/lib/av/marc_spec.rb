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

    describe :reader_for do
      it 'returns a reader for XML' do
        marc_path = 'spec/data/record-(cityarts)00002.xml'
        reader = Marc.reader_for(marc_path)
        record = reader.first
        expect(record['245'].value).to eq('826 Spelling Bee For Cheaters, February 17, 2011')
      end

      it 'returns a reader for binary MARC' do
        marc_path = 'spec/data/10.23.19.JessieLaCavalier.02.mrc'
        reader = Marc.reader_for(marc_path)
        record = reader.first
        expect(record['100'].value).to eq('LeCavalier, Jesse.')
      end

      it 'raises an error for non-MARC files' do
        marc_path = 'I am not a MARC file'
        expect { Marc.reader_for(marc_path) }.to raise_error(ArgumentError)
      end
    end

    describe :read do
      it 'reads XML' do
        marc_path = 'spec/data/record-(cityarts)00002.xml'
        record = Marc.read(marc_path)
        expect(record['245'].value).to eq('826 Spelling Bee For Cheaters, February 17, 2011')
      end

      it 'reads binary MARC' do
        marc_path = 'spec/data/10.23.19.JessieLaCavalier.02.mrc'
        record = Marc.read(marc_path)
        expect(record['100'].value).to eq('LeCavalier, Jesse.')
      end
    end
  end
end
