require 'spec_helper'
require 'av_core/metadata/fields'

module AVCore
  module Metadata
    module Fields
      describe Readers do
        describe :all do
          it 'parses the config' do
            expected_readers = [
              { order: 1, tag: '245', ind_1: nil, ind_2: nil, label: 'Title', subfields_separator: ' ', subfield_order: [:a] },
              { order: 2, tag: '520', ind_1: nil, ind_2: nil, label: 'Description', subfields_separator: ' ', subfield_order: [:a] },
              { order: 2, tag: '700', ind_1: nil, ind_2: nil, label: 'Creator', subfields_separator: ' ', subfield_order: nil },
              { order: 2, tag: '710', ind_1: nil, ind_2: nil, label: 'Creator', subfields_separator: ' ', subfield_order: nil },
              { order: 3, tag: '720', ind_1: nil, ind_2: nil, label: 'Contributor', subfields_separator: ' ', subfield_order: [:a] },
              { order: 4, tag: '711', ind_1: nil, ind_2: nil, label: 'Meeting Name', subfields_separator: ', ', subfield_order: %i[a n d c] },
              { order: 6, tag: '246', ind_1: nil, ind_2: nil, label: 'Variant Title', subfields_separator: ', ', subfield_order: nil },
              { order: 9, tag: '260', ind_1: nil, ind_2: nil, label: 'Published', subfields_separator: ', ', subfield_order: nil },
              { order: 10, tag: '250', ind_1: nil, ind_2: nil, label: 'Edition', subfields_separator: ', ', subfield_order: nil },
              { order: 11, tag: '856', ind_1: '4', ind_2: '1', label: 'Linked Resources', subfields_separator: ' ', subfield_order: nil },
              { order: 14, tag: '982', ind_1: nil, ind_2: nil, label: 'Full Collection Name', subfields_separator: ', ', subfield_order: [:b] },
              { order: 15, tag: '490', ind_1: nil, ind_2: nil, label: 'Series', subfields_separator: ', ', subfield_order: [:a] },
              { order: 16, tag: '020', ind_1: nil, ind_2: nil, label: 'ISBN', subfields_separator: ' ', subfield_order: nil },
              { order: 17, tag: '022', ind_1: nil, ind_2: nil, label: 'ISSN', subfields_separator: ' ', subfield_order: nil },
              { order: 20, tag: '024', ind_1: '8', ind_2: '0', label: 'Other Identifiers', subfields_separator: ' ', subfield_order: [:a] },
              { order: 21, tag: '600', ind_1: nil, ind_2: nil, label: 'Subject (Person)', subfields_separator: ' ', subfield_order: nil },
              { order: 22, tag: '610', ind_1: nil, ind_2: nil, label: 'Subject (Corporate)', subfields_separator: ' ', subfield_order: [:a] },
              { order: 23, tag: '650', ind_1: nil, ind_2: nil, label: 'Subject (Topic)', subfields_separator: ' ', subfield_order: [:a] },
              { order: 24, tag: '611', ind_1: nil, ind_2: nil, label: 'Subject (Meeting Name)', subfields_separator: ' ', subfield_order: [:a] },
              { order: 25, tag: '630', ind_1: nil, ind_2: nil, label: 'Subject (Uniform Title)', subfields_separator: ' ', subfield_order: [:a] },
              { order: 27, tag: '651', ind_1: nil, ind_2: nil, label: 'Geographic Coverage', subfields_separator: ' ', subfield_order: [:a] },
              { order: 28, tag: '508', ind_1: nil, ind_2: nil, label: 'Credits', subfields_separator: ', ', subfield_order: [:a] },
              { order: 29, tag: '255', ind_1: nil, ind_2: nil, label: 'Scale', subfields_separator: ', ', subfield_order: [:a] },
              { order: 30, tag: '255', ind_1: nil, ind_2: nil, label: 'Projection', subfields_separator: ', ', subfield_order: [:b] },
              { order: 31, tag: '255', ind_1: nil, ind_2: nil, label: 'Coordinates', subfields_separator: ', ', subfield_order: [:c] },
              { order: 32, tag: '392', ind_1: nil, ind_2: nil, label: 'Sheet Name', subfields_separator: ', ', subfield_order: [:c] },
              { order: 33, tag: '392', ind_1: nil, ind_2: nil, label: 'Sheet Number', subfields_separator: ', ', subfield_order: [:d] },
              { order: 34, tag: '336', ind_1: nil, ind_2: nil, label: 'Type', subfields_separator: ', ', subfield_order: [:a] },
              { order: 35, tag: '655', ind_1: nil, ind_2: nil, label: 'Format', subfields_separator: ' ', subfield_order: [:a] },
              { order: 36, tag: '300', ind_1: nil, ind_2: nil, label: 'Extent', subfields_separator: ' ', subfield_order: [:a] },
              { order: 37, tag: '300', ind_1: nil, ind_2: nil, label: 'Other Physical Details', subfields_separator: ' ', subfield_order: [:b] },
              { order: 38, tag: '300', ind_1: nil, ind_2: nil, label: 'Dimensions', subfields_separator: ' ', subfield_order: [:c] },
              { order: 39, tag: '306', ind_1: nil, ind_2: nil, label: 'Duration', subfields_separator: ', ', subfield_order: [:a] },
              { order: 40, tag: '340', ind_1: nil, ind_2: nil, label: 'Physical Medium', subfields_separator: ' ', subfield_order: [:a] },
              { order: 41, tag: '340', ind_1: nil, ind_2: nil, label: 'Colour/ B&W', subfields_separator: ' ', subfield_order: [:g] },
              { order: 42, tag: '340', ind_1: nil, ind_2: nil, label: 'Technical Specifications', subfields_separator: ' ', subfield_order: [:i] },
              { order: 43, tag: '546', ind_1: nil, ind_2: nil, label: 'Language', subfields_separator: ' ', subfield_order: [:a] },
              { order: 45, tag: '533', ind_1: nil, ind_2: nil, label: 'Repository', subfields_separator: ' ', subfield_order: [:c] },
              { order: 46, tag: '773', ind_1: nil, ind_2: nil, label: 'In', subfields_separator: ', ', subfield_order: nil },
              { order: 47, tag: '773', ind_1: nil, ind_2: '8', label: 'Digital Collection', subfields_separator: ' ', subfield_order: [:i] },
              { order: 48, tag: '363', ind_1: nil, ind_2: nil, label: 'Volume', subfields_separator: ' ', subfield_order: [:a] },
              { order: 49, tag: '363', ind_1: nil, ind_2: nil, label: 'Issue', subfields_separator: ' ', subfield_order: [:b] },
              { order: 51, tag: '787', ind_1: nil, ind_2: '8', label: 'Digital Exhibit', subfields_separator: ' ', subfield_order: [:i] },
              { order: 52, tag: '786', ind_1: nil, ind_2: '8', label: 'Collection in Repository', subfields_separator: ' ', subfield_order: [:i] },
              { order: 53, tag: '740', ind_1: nil, ind_2: nil, label: 'Text on Picture', subfields_separator: ', ', subfield_order: [:a] },
              { order: 54, tag: '751', ind_1: nil, ind_2: nil, label: 'Mentioned Place', subfields_separator: ', ', subfield_order: [:a] },
              { order: 56, tag: '789', ind_1: nil, ind_2: nil, label: 'Related Resource', subfields_separator: ' ', subfield_order: nil },
              { order: 57, tag: '790', ind_1: nil, ind_2: nil, label: 'Contributing Institution', subfields_separator: ' ', subfield_order: [:a] },
              { order: 58, tag: '852', ind_1: nil, ind_2: nil, label: 'Archive', subfields_separator: '; ', subfield_order: %i[a b c h] },
              { order: 60, tag: '500', ind_1: nil, ind_2: nil, label: 'Note', subfields_separator: ', ', subfield_order: nil },
              { order: 61, tag: '502', ind_1: nil, ind_2: nil, label: 'Dissertation/Thesis Note', subfields_separator: ', ', subfield_order: [:a] },
              { order: 63, tag: '522', ind_1: nil, ind_2: nil, label: 'Coverage', subfields_separator: ', ', subfield_order: [:a] },
              { order: 64, tag: '524', ind_1: nil, ind_2: nil, label: 'Preferred Citation', subfields_separator: ', ', subfield_order: [:a] },
              { order: 65, tag: '533', ind_1: nil, ind_2: nil, label: 'Reproduction Note', subfields_separator: ', ', subfield_order: [:a] },
              { order: 66, tag: '536', ind_1: nil, ind_2: nil, label: 'Grant Information', subfields_separator: ' ', subfield_order: %i[a o m n] },
              { order: 67, tag: '541', ind_1: nil, ind_2: nil, label: 'Provenance', subfields_separator: ', ', subfield_order: [:a] },
              { order: 68, tag: '541', ind_1: nil, ind_2: nil, label: 'Acquisition Method', subfields_separator: ', ', subfield_order: [:c] },
              { order: 69, tag: '541', ind_1: nil, ind_2: nil, label: 'Year of Admission', subfields_separator: ', ', subfield_order: [:d] },
              { order: 70, tag: '541', ind_1: nil, ind_2: nil, label: 'Owner', subfields_separator: ', ', subfield_order: [:f] },
              { order: 71, tag: '542', ind_1: nil, ind_2: nil, label: 'Standard Rights Statement', subfields_separator: ' ', subfield_order: [:f] },
              { order: 72, tag: '545', ind_1: nil, ind_2: nil, label: 'Note', subfields_separator: ', ', subfield_order: [:a] },
              { order: 73, tag: '542', ind_1: nil, ind_2: nil, label: 'Standard Rights Statement', subfields_separator: ' ', subfield_order: [:u] },
              { order: 85, tag: '540', ind_1: nil, ind_2: nil, label: 'Usage Statement', subfields_separator: ', ', subfield_order: [:a] },
              { order: 86, tag: '991', ind_1: nil, ind_2: nil, label: 'Access', subfields_separator: ', ', subfield_order: [:a] },
              { order: 89, tag: '982', ind_1: nil, ind_2: nil, label: 'Collection', subfields_separator: ' ', subfield_order: [:a] }
            ]
            readers = Readers.all
            expect(readers.size).to eq(expected_readers.size)
            aggregate_failures 'reader attributes' do
              readers.each_with_index do |r, index|
                exp = expected_readers[index]
                %i[order tag ind_1 ind_2 label subfields_separator subfield_order].each do |attr|
                  actual = r.send(attr)
                  expected = exp[attr]

                  expect(actual).to eq(expected), "expected #{attr} #{expected.inspect} at index #{index}, got #{actual.inspect}"
                end
              end
            end
          end

          it 'filters out duplicate fields' do
            num_542u = Readers.all.count { |r| r.tag == '542' && r.subfield_order == [:u] }
            expect(num_542u).to eq(1)
          end
        end
      end
    end
  end
end
