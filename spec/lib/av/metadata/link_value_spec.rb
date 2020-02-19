require 'spec_helper'

module AV
  class Metadata
    describe LinkValue do
      include AV::Constants

      describe :from_subfield_values do
        it 'reads an 856z' do
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

        it 'reads an 856y' do
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
      end
    end
  end
end
