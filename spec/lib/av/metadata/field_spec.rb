require 'spec_helper'
require 'marc'

module AV
  class Metadata
    describe Field do
      attr_reader :marc_record

      before(:each) do
        @marc_record = MARC::XMLReader.new('spec/data/record-(pacradio)01469.xml').first
      end

      it 'extracts the text from whole datafields' do
        field = Field.new(order: 2, label: 'Creator', spec: '700')
        value = field.value_from(marc_record)
        expect(value).to be_a(Value)

        expected_entries = [
          'Coleman, Wanda. interviewee.',
          'Adisa, Opal Palmer. interviewer.'
        ]
        expect(value.entries).to eq(expected_entries)
      end

      it 'extracts the text from subfields without groups' do
        field = Field.new(order: 85, label: 'Usage Statement', spec: '540$a')
        value = field.value_from(marc_record)
        expect(value).to be_a(Value)

        expected_entries = ['RESTRICTED.  Permissions, licensing requests, and all other inquiries should be directed in writing to: Director of the Archives, Pacifica Radio Archives, 3729 Cahuenga Blvd. West, North Hollywood, CA 91604, 800-735-0230 x 263, fax 818-506-1084, info@pacificaradioarchives.org, http://www.pacificaradioarchives.org']
        expect(value.entries).to eq(expected_entries)
      end

      # TODO: test multiple groups
      it 'extracts the text from grouped subfields' do
        field = Field.new(order: 66, label: 'Grant Information', spec: '536', subfield_order: %w[a o m n])
        value = field.value_from(marc_record)
        expect(value).to be_a(Value)
        expected_entries = ["Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project."]
        expect(value.entries).to eq(expected_entries)
      end

      it 'extracts links' do
        field = Field.new(order: 999, spec: '856{^1=\4}{^2=\1}', label: 'Linked Resources')
        value = field.value_from(marc_record)
        expect(value).to be_a(Value)
        expected_link = AV::Metadata::Link.new(url: 'http://oskicat.berkeley.edu/record=b23305522', body: 'View library catalog record.')
        expect(value.entries).to contain_exactly(expected_link)
      end

      describe :hash do
        it 'returns the same hash for identical Fields' do
          f1 = Field.new(order: 2, label: 'Description', spec: '520$a')
          f2 = Field.new(order: 2, label: 'Description', spec: '520$a')
          expect(f1).to eq(f2) # just to be sure

          expect(f1.hash).to eq(f2.hash)
        end
      end
    end
  end
end
