require 'spec_helper'

require 'marc'

module BerkeleyLibrary
  module AV
    class Metadata
      describe Fields do

        describe :standard_fields do
          it 'parses the config' do
            expected_fields = [
              Field.new(order: 1, spec: '245$a', label: 'Title'),
              Field.new(order: 2, spec: '520$a', label: 'Description'),
              Field.new(order: 2, spec: '700', label: 'Creator'),
              Field.new(order: 2, spec: '710', label: 'Creator'),
              Field.new(order: 3, spec: '720$a', label: 'Contributor'),
              Field.new(order: 4, spec: '711', label: 'Meeting Name', subfields_separator: ', ', subfield_order: %w[a n d c]),
              Field.new(order: 6, spec: '246', label: 'Variant Title', subfields_separator: ', '),
              Field.new(order: 9, spec: '260', label: 'Published', subfields_separator: ', '),
              Field.new(order: 10, spec: '250', label: 'Edition', subfields_separator: ', '),
              Field.new(order: 14, spec: '982$b', label: 'Full Collection Name', subfields_separator: ', '),
              Field.new(order: 15, spec: '490$a', label: 'Series', subfields_separator: ', '),
              Field.new(order: 16, spec: '020', label: 'ISBN'),
              Field.new(order: 17, spec: '022', label: 'ISSN'),
              Field.new(order: 20, spec: '024$a{^1=\8}{^2=\0}', label: 'Other Identifiers'),
              Field.new(order: 21, spec: '600', label: 'Subject (Person)'),
              Field.new(order: 22, spec: '610$a', label: 'Subject (Corporate)'),
              Field.new(order: 23, spec: '650$a', label: 'Subject (Topic)'),
              Field.new(order: 24, spec: '611$a', label: 'Subject (Meeting Name)'),
              Field.new(order: 25, spec: '630$a', label: 'Subject (Uniform Title)'),
              Field.new(order: 27, spec: '651$a', label: 'Geographic Coverage'),
              Field.new(order: 28, spec: '508$a', label: 'Credits', subfields_separator: ', '),
              Field.new(order: 29, spec: '255$a', label: 'Scale', subfields_separator: ', '),
              Field.new(order: 30, spec: '255$b', label: 'Projection', subfields_separator: ', '),
              Field.new(order: 31, spec: '255$c', label: 'Coordinates', subfields_separator: ', '),
              Field.new(order: 32, spec: '392$c', label: 'Sheet Name', subfields_separator: ', '),
              Field.new(order: 33, spec: '392$d', label: 'Sheet Number', subfields_separator: ', '),
              Field.new(order: 34, spec: '336$a', label: 'Type', subfields_separator: ', '),
              Field.new(order: 35, spec: '655$a', label: 'Format'),
              Field.new(order: 36, spec: '300$a', label: 'Extent'),
              Field.new(order: 37, spec: '300$b', label: 'Other Physical Details'),
              Field.new(order: 38, spec: '300$c', label: 'Dimensions'),
              Field.new(order: 39, spec: '306$a', label: 'Duration', subfields_separator: ', '),
              Field.new(order: 40, spec: '340$a', label: 'Physical Medium'),
              Field.new(order: 41, spec: '340$g', label: 'Colour/ B&W'),
              Field.new(order: 42, spec: '340$i', label: 'Technical Specifications'),
              Field.new(order: 43, spec: '546$a', label: 'Language'),
              Field.new(order: 45, spec: '533$c', label: 'Repository'),
              Field.new(order: 46, spec: '773', label: 'In', subfields_separator: ', '),
              Field.new(order: 47, spec: '773$i{^2=\8}', label: 'Digital Collection'),
              Field.new(order: 48, spec: '363$a', label: 'Volume'),
              Field.new(order: 49, spec: '363$b', label: 'Issue'),
              Field.new(order: 51, spec: '787$i{^2=\8}', label: 'Digital Exhibit'),
              Field.new(order: 52, spec: '786$i{^2=\8}', label: 'Collection in Repository'),
              Field.new(order: 53, spec: '740$a', label: 'Text on Picture', subfields_separator: ', '),
              Field.new(order: 54, spec: '751$a', label: 'Mentioned Place', subfields_separator: ', '),
              Field.new(order: 56, spec: '789', label: 'Related Resource'),
              Field.new(order: 57, spec: '790$a', label: 'Contributing Institution'),
              Field.new(order: 58, spec: '852', label: 'Archive', subfields_separator: '; ', subfield_order: %w[a b c h]),
              Field.new(order: 60, spec: '500', label: 'Note', subfields_separator: ', '),
              Field.new(order: 61, spec: '502$a', label: 'Dissertation/Thesis Note', subfields_separator: ', '),
              Field.new(order: 63, spec: '522$a', label: 'Coverage', subfields_separator: ', '),
              Field.new(order: 64, spec: '524$a', label: 'Preferred Citation', subfields_separator: ', '),
              Field.new(order: 65, spec: '533$a', label: 'Reproduction Note', subfields_separator: ', '),
              Field.new(order: 66, spec: '536', label: 'Grant Information', subfield_order: %w[a o m n]),
              Field.new(order: 67, spec: '541$a', label: 'Provenance', subfields_separator: ', '),
              Field.new(order: 68, spec: '541$c', label: 'Acquisition Method', subfields_separator: ', '),
              Field.new(order: 69, spec: '541$d', label: 'Year of Admission', subfields_separator: ', '),
              Field.new(order: 70, spec: '541$f', label: 'Owner', subfields_separator: ', '),
              Field.new(order: 71, spec: '542$f', label: 'Standard Rights Statement'),
              Field.new(order: 72, spec: '545$a', label: 'Note', subfields_separator: ', '),
              Field.new(order: 73, spec: '542$u', label: 'Standard Rights Statement'),
              Field.new(order: 85, spec: '540$a', label: 'Usage Statement', subfields_separator: ', '),
              Field.new(order: 86, spec: '991$a', label: 'Access', subfields_separator: ', '),
              Field.new(order: 89, spec: '982$a', label: 'Collection'),
              Field.new(order: 99, spec: '998', label: 'Tracks', subfield_order: %w[g t a]),
              Field.new(order: 999, spec: '856{^1=\4}{^2=\1}', label: 'Linked Resources')
            ]

            fields = Fields.default_fields
            expect(fields).to eq(expected_fields)
          end

          it 'filters out duplicates' do
            fields = Fields.default_fields
            duplicates = []

            fields.each_with_index do |f1, i|
              fields[(i + 1)..].each do |f2|
                if f1.same_metadata?(f2)
                  duplicates << [f1, f2]
                elsif f2.same_metadata?(f1)
                  duplicates << [f2, f1]
                end
              end
            end

            expect(duplicates).to eq([]) # better reporting than be_empty?
          end
        end

        describe :default_values_from do
          it 'reads an Alma record' do
            bib_number = 'b23305522'
            marc_record = alma_marc_record_for(bib_number)

            fields = Fields.default_fields.each_with_object({}) do |f, ff|
              ff[f.spec] = f
            end

            expected = {
              '245$a' => 'Title (245): Wanda Coleman',
              '520$a' => 'Description (520): Poet Opal Palmer Adisa interviews writer/poet Wanda Coleman, author of Mad Dog, Black Lady, African Sleeping Sickness and Hand Dance, among other books. Coleman discusses when she found her poetic voice, talks about the function of poetry, her personal encounters with anti-Black discrimination, and about the reluctance of white liberals to discuss issues that affect the Black community. She also talks about the plight of the African American community in South Central Los Angeles. The poems Coleman reads are A civilized plague, David Polion, Notes of a cultural terrorist and Jazz wazz.',
              '700' => 'Creator (700): Coleman, Wanda. interviewee. Adisa, Opal Palmer. interviewer.',
              '710' => 'Creator (710): Pacifica Radio Archive. KPFA (Radio station : Berkeley, Calif.).',
              '260' => 'Published (260): Los Angeles :, Pacifica Radio Archives,, 1993.',
              '300$a' => 'Extent (300): 1 online resource.',
              '533$c' => 'Repository (533): Pacifica Radio Archives.',
              '533$a' => 'Reproduction Note (533): Electronic reproduction.',
              '536' => "Grant Information (536): Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project.",
              '540$a' => 'Usage Statement (540): RESTRICTED.',
              '998' => 'Tracks (998): PRA_NHPRC1_AZ1084_00_000_00.mp3 00:54:03'
            }.each_with_object({}) do |(k, v), x|
              field = fields[k]
              x[field] = v
            end

            actual = Fields.default_values_from(marc_record)
            expect(actual.keys).to eq(expected.keys)

            aggregate_failures do
              expected.each do |f, xv|
                actual_value = actual[f]
                expect(actual_value.to_s).to eq(xv), "Wrong value for field #{f}: expected #{xv}, got #{actual_value}"
              end
            end
          end

          it 'reads a TIND record' do
            marc_record = MARC::XMLReader.new('spec/data/record-(pacradio)01469.xml').first

            fields = Fields.default_fields.each_with_object({}) do |f, ff|
              ff[f.spec] = f
            end

            expected = {
              '245$a' => 'Title (245): Wanda Coleman',
              '520$a' => 'Description (520): Poet Opal Palmer Adisa interviews writer/poet Wanda Coleman, author of Mad Dog, Black Lady, African Sleeping Sickness and Hand Dance, among other books. Coleman discusses when she found her poetic voice, talks about the function of poetry, her personal encounters with anti-Black discrimination, and about the reluctance of white liberals to discuss issues that affect the Black community. She also talks about the plight of the African American community in South Central Los Angeles. The poems Coleman reads are A civilized plague, David Polion, Notes of a cultural terrorist and Jazz wazz.',
              '700' => 'Creator (700): Coleman, Wanda. interviewee. Adisa, Opal Palmer. interviewer.',
              '710' => 'Creator (710): Pacifica Radio Archive. KPFA (Radio station : Berkeley, Calif.).',
              '260' => 'Published (260): Los Angeles, Pacifica Radio Archives, 1993.',
              '982$b' => 'Full Collection Name (982): Pacifica Radio Archives Social Activism Sound Recording Project',
              '336$a' => 'Type (336): Audio',
              '300$a' => 'Extent (300): 1 online resource.',
              '852' => 'Archive (852): The Library',
              '536' => "Grant Information (536): Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project.",
              '540$a' => 'Usage Statement (540): RESTRICTED.  Permissions, licensing requests, and all other inquiries should be directed in writing to: Director of the Archives, Pacifica Radio Archives, 3729 Cahuenga Blvd. West, North Hollywood, CA 91604, 800-735-0230 x 263, fax 818-506-1084, info@pacificaradioarchives.org, http://www.pacificaradioarchives.org',
              '982$a' => 'Collection (982): Pacifica Radio Archives',
              '998' => 'Tracks (998): PRA_NHPRC1_AZ1084_00_000_00.mp3 00:54:03'
            }.each_with_object({}) do |(k, v), x|
              field = fields[k]
              x[field] = v
            end

            actual = Fields.default_values_from(marc_record)
            expect(actual.keys).to eq(expected.keys)

            aggregate_failures do
              expected.each do |f, xv|
                actual_value = actual[f].to_s
                expect(actual_value).to eq(xv), "Wrong value for field #{f.inspect}: expected #{xv.inspect}, got #{actual_value.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
