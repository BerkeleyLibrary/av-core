require 'spec_helper'

module AV
  describe Record do
    before do
      Config.avplayer_base_uri = 'https://avplayer.lib.berkeley.edu'
      Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
      Config.alma_sru_host = 'berkeley.alma.exlibrisgroup.com'
      Config.alma_institution_code = '01UCS_BER'
      Config.alma_primo_host = 'search.library.berkeley.edu'
      Config.alma_permalink_key = 'iqob43'
    end

    after do
      Config.send(:clear!)
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
      it 'returns a player URI based on the bib number for Millennium records' do
        bib_number = 'b22139658'
        stub_sru_request(bib_number)

        collection = 'MRCVideo'
        record = Record.from_metadata(collection:, record_id: bib_number)

        expected_uri = URI.parse("https://avplayer.lib.berkeley.edu/#{collection}/#{bib_number}")
        expect(record.player_uri).to eq(expected_uri)
      end

      it 'returns a player URI based on the record ID for TIND records' do
        tind_035 = '(pacradio)01469'
        marc_xml = File.read("spec/data/record-#{tind_035}.xml")
        search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        collection = 'Pacifica'
        record = Record.from_metadata(collection:, record_id: tind_035)

        expected_uri = URI.parse("https://avplayer.lib.berkeley.edu/#{collection}/#{tind_035}")
        expect(record.player_uri).to eq(expected_uri)
      end

      it 'generates the player URI' do
        collection = 'MRCAudio'
        bib_number = 'b11082434'

        metadata = instance_double(Metadata)
        expect(metadata).to receive(:record_id).and_return(bib_number)

        record = Record.new(collection:, tracks: [], metadata:)

        expected_uri = URI.parse("https://avplayer.lib.berkeley.edu/#{collection}/#{bib_number}")
        expect(record.player_uri).to eq(expected_uri)
      end
    end

    describe :display_uri do
      it 'returns the display URI' do
        collection = 'MRCAudio'
        bib_number = 'b11082434'
        expected_uri = URI.parse("http://oskicat.example.edu/record=#{bib_number}")

        metadata = instance_double(Metadata)
        expect(metadata).to receive(:display_uri).and_return(expected_uri)

        record = Record.new(collection:, tracks: [], metadata:)
        expect(record.display_uri).to eq(expected_uri)
      end
    end

    describe :type_label do
      it 'handles audio' do
        t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'MRCAudio/frost-read1.mp3')
        t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'MRCAudio/frost-read2.mp3')
        record = Record.new(
          collection: 'MRCAudio',
          tracks: [t2, t1],
          metadata: instance_double(Metadata)
        )

        expect(record.type_label).to eq('Audio')
      end

      it 'handles video' do
        t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'MRCAudio/frost-read1.mp4')
        t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'MRCAudio/frost-read2.mp4')
        record = Record.new(
          collection: 'MRCVideo',
          tracks: [t2, t1],
          metadata: instance_double(Metadata)
        )

        expect(record.type_label).to eq('Video')
      end

      it 'handles mixed records' do
        t1 = Track.new(sort_order: 1, title: 'Part 1', path: 'MRCAudio/frost-read1.mp3')
        t2 = Track.new(sort_order: 2, title: 'Part 2', path: 'MRCAudio/frost-read2.mp4')
        record = Record.new(
          collection: 'MRCAudioVideo',
          tracks: [t2, t1],
          metadata: instance_double(Metadata)
        )

        expect(record.type_label).to eq('Audio / Video')
      end
    end

    describe :description do
      it 'gets the description from the 520 tag' do
        bib_number = 'b22139658'
        stub_sru_request(bib_number)

        marc_record = alma_marc_record_for(bib_number)
        expected_desc = marc_record['520']['a']

        record = Record.from_metadata(collection: 'MRCVideo', record_id: bib_number)
        expect(record.description).to eq(expected_desc)
      end
    end

    describe :tind_id do
      it 'returns nil for Millennium records' do
        bib_number = 'b22139658'
        stub_sru_request(bib_number)
        record = Record.from_metadata(collection: 'MRCVideo', record_id: bib_number)
        expect(record.tind_id).to be_nil
      end

      it 'returns the TIND ID for TIND records' do
        marc_xml = File.read('spec/data/record-(pacradio)01469.xml')
        search_url = 'https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22%28pacradio%2901469%22&of=xm'
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        record = Record.from_metadata(
          collection: 'Pacifica',
          record_id: '(pacradio)01469'
        )
        expected_id = RecordId.new('21178')
        expect(record.tind_id).to eq(expected_id)
      end
    end

    describe :bib_number do
      it 'returns nil for Alma records with no bib number' do
        mms_id = '991034756419706532'
        stub_sru_request(mms_id)
        record = Record.from_metadata(collection: 'Video-Public-Bancroft', record_id: mms_id)
        expect(record.bib_number).to be_nil
      end

      it 'returns nil for TIND records with no bib number' do
        tind_id = '(clir)00020'
        marc_xml = File.read('spec/data/record-(clir)00020.xml')
        search_url = 'https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22%28clir%2900020%22&of=xm'
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        record = Record.from_metadata(collection: 'Video-Public-Bancroft', record_id: tind_id)
        expect(record.bib_number).to be_nil
      end
    end

    describe :from_metadata do
      it 'loads the metadata' do
        marc_xml = File.read('spec/data/record-(pacradio)01469.xml')
        search_url = 'https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22%28pacradio%2901469%22&of=xm'
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        record = Record.from_metadata(collection: 'Pacifica', record_id: '(pacradio)01469')

        tracks = record.tracks
        expect(tracks.size).to eq(1)
        track = tracks[0]
        expect(track.sort_order).to eq(0)
        expect(track.title).to be_nil
        expect(track.path).to eq('Pacifica/PRA_NHPRC1_AZ1084_00_000_00.mp3')
        expect(track.duration).to eq(AV::Types::Duration.from_string('00:54:03'))

        record.metadata.tap do |metadata|
          expect(metadata.bib_number).to eq('b23305522')
          values = metadata.values_by_field.values

          expected = [
            'Title (245): Wanda Coleman',
            'Description (520): Poet Opal Palmer Adisa interviews writer/poet Wanda Coleman, author of Mad Dog, Black Lady, African Sleeping Sickness and Hand Dance, among other books. Coleman discusses when she found her poetic voice, talks about the function of poetry, her personal encounters with anti-Black discrimination, and about the reluctance of white liberals to discuss issues that affect the Black community. She also talks about the plight of the African American community in South Central Los Angeles. The poems Coleman reads are A civilized plague, David Polion, Notes of a cultural terrorist and Jazz wazz.',
            'Creator (700): Coleman, Wanda. interviewee. Adisa, Opal Palmer. interviewer.',
            'Creator (710): Pacifica Radio Archive. KPFA (Radio station : Berkeley, Calif.).',
            'Published (260): Los Angeles, Pacifica Radio Archives, 1993.',
            'Full Collection Name (982): Pacifica Radio Archives Social Activism Sound Recording Project',
            'Type (336): Audio',
            'Extent (300): 1 online resource.',
            'Archive (852): The Library',
            "Grant Information (536): Sponsored by the National Historical Publications and Records Commission at the National Archives and Records Administration as part of Pacifica's American Women Making History and Culture: 1963-1982 grant preservation project.",
            'Usage Statement (540): RESTRICTED.  Permissions, licensing requests, and all other inquiries should be directed in writing to: Director of the Archives, Pacifica Radio Archives, 3729 Cahuenga Blvd. West, North Hollywood, CA 91604, 800-735-0230 x 263, fax 818-506-1084, info@pacificaradioarchives.org, http://www.pacificaradioarchives.org',
            'Collection (982): Pacifica Radio Archives',
            'Tracks (998): PRA_NHPRC1_AZ1084_00_000_00.mp3 00:54:03',
            'Linked Resources (856): [View record in Digital Collections.](https://digicoll.lib.berkeley.edu/record/21178)'
          ]
          expect(values.size).to eq(expected.size)
          aggregate_failures 'fields' do
            values.each_with_index { |f, i| expect(f.to_s).to eq(expected[i]) }
          end

          expect(record.title).to eq(metadata.title)
          expect(record.bib_number).to eq(metadata.bib_number)
        end
      end

      it "raises #{AV::RecordNotFound} if the record cannot be found" do
        search_url = 'https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22%28pacradio%2901469%22&of=xm'
        stub_request(:get, search_url).to_return(status: 404)
        expect do
          Record.from_metadata(
            collection: 'Pacifica',
            record_id: '(pacradio)01469'
          )
        end.to raise_error(AV::RecordNotFound)
      end
    end

    describe :calnet_or_ip? do
      it 'returns true for restricted, false for unrestricted' do
        restricted = %w[b18538031 b24071548 (cityarts)00002 (cityarts)00773]
        unrestricted = %w[b22139658 b23161018 (pacradio)00107 (pacradio)01469]
        (restricted + unrestricted).each do |record_id|
          source = Metadata::Source.for_record_id(record_id)
          if source == Metadata::Source::TIND
            test_data = "spec/data/record-#{record_id}.xml"
            stub_request(:get, source.marc_uri_for(record_id)).to_return(status: 200, body: File.read(test_data))
          else
            stub_sru_request(record_id)
          end
        end

        aggregate_failures 'restrictions' do
          restricted.each do |record_id|
            record = Record.from_metadata(collection: 'test', record_id:)
            expect(record.calnet_or_ip?).to eq(true), "Expected #{record_id} to be restricted, was not"
          end

          unrestricted.each do |record_id|
            record = Record.from_metadata(collection: 'test', record_id:)
            expect(record.calnet_or_ip?).to eq(false), "Expected #{record_id} not to be restricted, was"
          end
        end
      end
    end

    describe :calnet_only? do
      it 'returns true for CalNet-only records' do
        mms_id = '991047179369706532'
        stub_sru_request(mms_id)
        record = Record.from_metadata(collection: 'test', record_id: mms_id)
        expect(record.calnet_or_ip?).to eq(true)
        expect(record.calnet_only?).to eq(true)
      end

      it 'returns false for records open to UCB IP addresses' do
        mms_id = '991054360089706532'
        stub_sru_request(mms_id)
        record = Record.from_metadata(collection: 'test', record_id: mms_id)
        expect(record.calnet_or_ip?).to eq(true)
        expect(record.calnet_only?).to eq(false)
      end
    end
  end
end
