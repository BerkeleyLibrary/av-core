require 'spec_helper'
require 'av/record'
require 'av/metadata'

module AV
  describe Record do
    describe :new do
      it 'sorts the tracks' do
        t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'frost-read1.mp3')
        t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'frost-read2.mp3')
        record = Record.new(
          tracks: [t2, t1],
          metadata: instance_double(Metadata)
        )
        tracks = record.tracks
        expect(tracks[0]).to eq(t1)
        expect(tracks[1]).to eq(t2)
      end
    end

    describe :from_metadata do
      before(:each) do
        AV::Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
      end

      after(:each) do
        AV::Config.instance_variable_set(:@tind_base_uri, nil)
      end

      it 'loads the metadata' do
        marc_xml = File.read('spec/data/record-21178.xml')
        search_url = 'https://digicoll.lib.berkeley.edu/record/21178/export/xm'
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        record = Record.from_metadata(record_id: '21178', metadata_source: AV::Metadata::Source::TIND)

        tracks = record.tracks
        expect(tracks.size).to eq(1)
        track = tracks[0]
        expect(track.sort_order).to eq(0)
        expect(track.title).to be_nil
        expect(track.path).to eq('PRA_NHPRC1_AZ1084_00_000_00.mp3')
        expect(track.duration).to eq(AV::Types::Duration.from_string('00:54:03'))

        record.metadata.tap do |metadata|
          expect(metadata.bib_number).to eq('b23305522')
          values = metadata.values

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
            'Collection (982): Pacifica Radio Archives',
            'Tracks (998): PRA_NHPRC1_AZ1084_00_000_00.mp3 00:54:03'
          ]
          expect(values.size).to eq(expected.size)
          aggregate_failures 'fields' do
            values.each_with_index do |f, i|
              expect(f.to_s.gsub('|', '')).to eq(expected[i])
            end
          end

          expect(record.title).to eq(metadata.title)
          expect(record.bib_number).to eq(metadata.bib_number)
        end
      end

    end
  end
end
