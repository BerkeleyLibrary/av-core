require 'spec_helper'

module AV
  class Metadata
    describe LinkValue do
      include AV::Constants

      describe :from_subfield_values do
        it 'reads an 856 z' do
          marc_html = File.read('spec/data/b11082434.html')
          marc_record = AV::Marc::Millennium.marc_from_html(marc_html)

          field = AV::Metadata::Field.new(
            label: 'Link to online version(s)',
            tag: TAG_LINK_FIELD,
            ind_1: '4',
            ind_2: '0',
            order: nil
          )

          value = field.value_from(marc_record)
          links = value.links
          expect(links.size).to eq(1)

          link = links[0]
          expect(link.body).to eq('MRC online audio. Freely available.')
          expect(link.url).to eq('https://avplayer.lib.berkeley.edu/MRCAudio/b11082434')
        end

        it 'reads an 856 y' do
          marc_record = MARC::XMLReader.new('spec/data/record-4188.xml').first

          field = AV::Metadata::Field.new(
            label: 'Linked Resources',
            tag: TAG_LINK_FIELD,
            ind_1: '4',
            ind_2: '1',
            order: nil
          )

          # noinspection RubyYardParamTypeMatch
          value = field.value_from(marc_record)
          links = value.links
          expect(links.size).to eq(1)

          link = links[0]
          expect(link.body).to eq('View library catalog record.')
          expect(link.url).to eq('http://oskicat.berkeley.edu/record=b18538031')
        end

        it 'reads multiple links, with both 856 z and 856 3' do
          marc_html = File.read('spec/data/b20786580.html')
          marc_record = AV::Marc::Millennium.marc_from_html(marc_html)

          field = AV::Metadata::Field.new(
            label: 'Link to online version(s)',
            tag: TAG_LINK_FIELD,
            ind_1: '4',
            ind_2: '0',
            order: nil
          )

          value = field.value_from(marc_record)
          links = value.links
          expect(links.size).to eq(3)

          expected_links = [
            Link.new(
              body: 'Part 1: Citizens Reach Out Iraqi refugee interviews. Freely available for streaming.',
              url: 'http://www.lib.berkeley.edu/video/OhF77lO8EeOXw-SypF1fwQ'
            ),
            Link.new(
              body: 'Part 2: Citizens Reach Out Iraqi refugee interviews. Freely available for streaming.',
              url: 'http://www.lib.berkeley.edu/video/Xl5i3FO8EeOXw-SypF1fwQ'
            ),
            Link.new(
              body: 'Part 3: Citizens Reach Out Iraqi refugee interviews. Freely available for streaming.',
              url: 'http://www.lib.berkeley.edu/video/cxvVnFO8EeOXw-SypF1fwQ'
            )
          ]

          expect(links).to contain_exactly(*expected_links)
        end
      end
    end
  end
end
