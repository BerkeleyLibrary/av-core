require 'spec_helper'

module AV
  describe Record do
    before(:each) do
      Config.avplayer_base_uri = 'https://avplayer.lib.berkeley.edu'
      Config.millennium_base_uri = 'http://oskicat.berkeley.edu/search~S1'
      Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
    end

    after(:each) do
      Config.instance_variable_set(:@millennium_base_uri, nil)
      Config.instance_variable_set(:@tind_base_uri, nil)
      Config.instance_variable_set(:@avplayer_base_uri, nil)
    end

    describe :new do
      it 'sorts the tracks' do
        t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'MRCAudio/frost-read1.mp3')
        t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'MRCAudio/frost-read2.mp3')
        record = Record.new(
          collection: 'MRCAudio',
          tracks: [t2, t1],
          metadata: instance_double(Metadata)
        )
        tracks = record.tracks
        expect(tracks[0]).to eq(t1)
        expect(tracks[1]).to eq(t2)
      end
    end

    describe :player_uri do
      it 'generates the player URI' do
        collection = 'MRCAudio'
        bib_number = 'b11082434'

        metadata = instance_double(Metadata)
        expect(metadata).to receive(:bib_number).and_return(bib_number)

        record = Record.new(collection: collection, tracks: [], metadata: metadata)

        expected_uri = URI.parse("https://avplayer.lib.berkeley.edu/#{collection}/#{bib_number}")
        expect(record.player_uri).to eq(expected_uri)
      end
    end

    describe :description do
      it 'gets the description from the 520 tag' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))

        desc_text = <<~DESC
          An American propaganda documentary created "to inform and
          impress on American citizens the true nature and the true
          magnitude of those forces that are working within our
          nation for its overthrow...and the destruction of our
          educational system." Film covers the July 1969 California
          Revolutionary Conference and other demonstrations, warning
          against the activities of Students for a Democratic
          Society, the Black Panthers, student protestors and
          Vietnam War demonstrators as they promote a "socialist/
          communist overthrow of the U.S. government," taking as
          their mentor Chairman Mao Tse-Tung.
        DESC
        expected_desc = desc_text.gsub(/[[:space:]]+/, ' ').strip

        record = Record.from_metadata(collection: 'MRCVideo', record_id: 'b22139658')
        expect(record.description).to eq(expected_desc)
      end
    end

    describe :from_metadata do
      it 'loads the metadata' do
        marc_xml = File.read('spec/data/record-21178.xml')
        search_url = 'https://digicoll.lib.berkeley.edu/record/21178/export/xm'
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        record = Record.from_metadata(
          collection: 'Pacifica',
          record_id: '21178'
        )

        tracks = record.tracks
        expect(tracks.size).to eq(1)
        track = tracks[0]
        expect(track.sort_order).to eq(0)
        expect(track.title).to be_nil
        expect(track.path).to eq('Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3')
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

      it "raises #{AV::RecordNotFound} if the record cannot be found" do
        search_url = 'https://digicoll.lib.berkeley.edu/record/21178/export/xm'
        stub_request(:get, search_url).to_return(status: 404)
        expect do
          Record.from_metadata(
            collection: 'Pacifica',
            record_id: '21178'
          )
        end.to raise_error(AV::RecordNotFound)
      end
    end
  end
end
