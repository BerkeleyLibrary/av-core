require 'spec_helper'
require 'marc'

module BerkeleyLibrary
  module AV
    class Metadata
      describe Field do
        attr_reader :marc_record

        before do
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

        context 'links' do
          it 'extracts links from TIND records' do
            field = Field.new(order: 9999, label: 'Link to Content', spec: '856{^1=\4}{^2=\2}', subfield_order: %w[u y])
            value = field.value_from(marc_record)
            expect(value).to be_a(Value)
            expected_link = AV::Metadata::Link.new(
              url: 'https://avplayer.lib.berkeley.edu/Pacifica/b23305522',
              body: 'Play Audio for American Women Making History and Culture. Freely available for streaming.'
            )
            expect(value.entries).to contain_exactly(expected_link)
          end

          it 'extracts links from Alma records' do
            marc_record = MARC::XMLReader.new('spec/data/alma/991054360089706532-sru.xml').first
            field = Field.new(order: 9999, label: 'Link to Content', spec: '956{^1=\4}{^2=\0}', subfield_order: %w[u z])
            value = field.value_from(marc_record)
            expect(value).to be_a(Value)
            expected_link = AV::Metadata::Link.new(
              url: 'https://avplayer.lib.berkeley.edu/Video-UCBOnly-MRC/b25716973',
              body: 'UCB Access.'
            )
            expect(value.entries).to contain_exactly(expected_link)
          end
        end

        context 'transcripts' do
          it 'extracts transcripts from TIND records' do
            marc_record = MARC::XMLReader.new('spec/data/record-audio-multiple-856s.xml').first
            field = Field.new(order: 999, label: 'Transcripts', spec: "#{TAG_TRANSCRIPT_FIELD}{$y~\\Transcript}{^1=\\4}{^2=\\2}", subfield_order: %w[u y])
            value = field.value_from(marc_record)
            expect(value).to be_a(Value)
            expected_transcript = AV::Metadata::Link.new(
              url: 'https://digitalassets.lib.berkeley.edu/audio/transcript/Carol_Fewell_Billings_Transcript.pdf',
              body: 'Transcript of audio file'
            )
            expect(value.entries).to contain_exactly(expected_transcript)
          end

          it 'doesn\'t break when there are no transcripts' do
            marc_record = MARC::XMLReader.new('spec/data/record-(pacradio)01469.xml').first
            field = Field.new(order: 999, label: 'Transcripts', spec: "#{TAG_TRANSCRIPT_FIELD}{$y~\\Transcript}{^1=\\4}{^2=\\2}", subfield_order: %w[u y])
            value = field.value_from(marc_record)
            expect(value).to be_nil
          end
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
end
