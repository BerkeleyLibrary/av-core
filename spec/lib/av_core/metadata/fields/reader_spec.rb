require 'spec_helper'

require 'marc'
require 'av_core/metadata/fields'

module AVCore
  module Metadata
    module Fields
      describe Reader do
        attr_reader :marc_record

        before(:all) do
          @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
        end

        describe :<=> do
          it 'treats fields that differ only in subfield order as different' do
            args1 = { order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c] }
            args2 = args1.merge(subfield_order: %i[c n d a])
            ff1 = Reader.new(args1)
            ff2 = Reader.new(args2)
            expect(ff1 < ff2).to be_truthy
            expect(ff2 > ff1).to be_truthy
          end
        end

        describe :to_s do
          it 'includes all pertinent info' do
            ff = Reader.new(order: 4, tag: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[c n d a])
            ffs = ff.to_s
            ['4', '711', 'Meeting Name'].each { |v| expect(ffs).to include(v) }
          end
        end

        describe Readers::TRACKS do
          require 'av_core/metadata'
          it 'extracts the tracks' do
            marc_html = File.read('spec/data/b23161018.html')
            marc_record = AVCore::Metadata::MillenniumMARCExtractor.new(marc_html).extract_marc_record
            field = Readers::TRACKS.create_field(marc_record)
            expect(field).not_to(be_nil) # TODO: better support for repeated subfields
          end
        end
      end
    end
  end
end
