require 'spec_helper'

require 'av_core/metadata/fields'

module AVCore
  module Metadata
    describe Fields do
      describe :fields_from do
        attr_reader :marc_record

        before(:all) do
          marc_xml = File.read('spec/data/record-21178.xml')
          input = StringIO.new(marc_xml)
          @marc_record = MARC::XMLReader.new(input).first
        end

        # rubocop:disable Metrics/LineLength
        it 'parses the fields' do
          expected = [
            'Title (245): Wanda Coleman',
            'Description (520): Poet Opal Palmer Adisa interviews writer/poet Wanda Coleman, author of Mad Dog, Black Lady, African Sleeping Sickness and Hand Dance, among other books. Coleman discusses when she found her poetic voice, talks about the function of poetry, her personal encounters with anti-Black discrimination, and about the reluctance of white liberals to discuss issues that affect the Black community. She also talks about the plight of the African American community in South Central Los Angeles. The poems Coleman reads are A civilized plague, David Polion, Notes of a cultural terrorist and Jazz wazz.',
            'Creator (700): Coleman, Wanda. interviewee. Adisa, Opal Palmer. interviewer.',
            'Creator (710): Pacifica Radio Archive. KPFA (Radio station : Berkeley, Calif.).',
            'Published (260): Los Angeles , Pacifica Radio Archives, 1993.',
            'Linked Resources (856): [View library catalog record.](http://oskicat.berkeley.edu/record=b23305522)',
            'Full Collection Name (982): Pacifica Radio Archives Social Activism Sound Recording Project',
            'Type (336): Audio',
            'Extent (300): 1 online resource.',
            'Archive (852): The Library',
            "Grant Information (536): Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project.",
            'Usage Statement (540): RESTRICTED.  Permissions, licensing requests, and all other inquiries should be directed in writing to: Director of the Archives, Pacifica Radio Archives, 3729 Cahuenga Blvd. West, North Hollywood, CA 91604, 800-735-0230 x 263, fax 818-506-1084, info@pacificaradioarchives.org, http://www.pacificaradioarchives.org',
            'Collection (982): Pacifica Radio Archives'
          ]

          fields = Fields.fields_from(marc_record)
          expect(fields.size).to eq(expected.size)
          fields.each_with_index do |f, i|
            expect(f.to_s.gsub('|', '')).to eq(expected[i])
          end
        end
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
