require 'spec_helper'

module AV
  describe Metadata do
    before(:each) do
      AV::Config.millennium_base_uri = 'http://oskicat.berkeley.edu/'
    end

    after(:each) do
      AV::Config.instance_variable_set(:@millennium_base_uri, nil)
    end

    describe :title do
      it 'finds the title' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
        metadata = Metadata.for_record(record_id: 'b22139658')
        expect(metadata.title).to eq('Communists on campus')
      end

      it 'returns UNKNOWN_TITLE if the title cannot be found' do
        marc_record = Marc::Millennium.marc_from_html(File.read('spec/data/b22139658.html'))
        marc_record.fields.delete_if { |f| f.tag == AV::Constants::TAG_TITLE_FIELD }
        metadata = Metadata.new(record_id: 'b22139658', source: Metadata::Source::MILLENNIUM, marc_record: marc_record)
        expect(metadata.title).to eq(Metadata::UNKNOWN_TITLE)
      end
    end

    describe :ucb_access? do
      it 'detects restricted audio' do
        bib_number = 'b18538031'
        stub_request(:get, Metadata::Source::MILLENNIUM.marc_uri_for(bib_number))
          .to_return(status: 200, body: File.read("spec/data/#{bib_number}.html"))
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(true)
      end

      it 'detects restricted video' do
        bib_number = 'b25207857'
        stub_request(:get, Metadata::Source::MILLENNIUM.marc_uri_for(bib_number))
          .to_return(status: 200, body: File.read("spec/data/#{bib_number}.html"))
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(true)
      end
    end

    describe :for_record do
      it "raises #{AV::RecordNotFound} for an ID with indeterminate source" do
        expect do
          Metadata.for_record(record_id: 'abcdefg')
        end.to raise_error(AV::RecordNotFound)
      end
    end

    describe :title do
      it 'collapses spaces after hyphens' do
        bib_number = 'b22139647'
        stub_request(:get, Metadata::Source::MILLENNIUM.marc_uri_for(bib_number))
          .to_return(status: 200, body: File.read("spec/data/#{bib_number}.html"))
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.title).to eq('Europe and the nuclear arms race, with David Owen and co-host Prof. Thomas Barnes')
      end
    end

    describe :values do
      before(:each) do
        AV::Config.millennium_base_uri = 'http://oskicat.berkeley.edu/'
      end

      after(:each) do
        AV::Config.instance_variable_set(:@millennium_base_uri, nil)
      end

      it 'injects the catalog URL if not present' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
        metadata = Metadata.for_record(record_id: 'b22139658')

        link_value = metadata.values.find { |v| Metadata::Fields::CATALOG_LINK.value?(v) }
        expect(link_value).not_to be_nil

        links = link_value.links
        expect(links.size).to eq(1)

        link = links[0]
        expect(link.body).to eq('View library catalog record.')
        expect(link.url).to eq('http://oskicat.berkeley.edu/record=b22139658')
      end
    end

    describe :player_url do
      it 'finds the player_url' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
        metadata = Metadata.for_record(record_id: 'b22139658')
        expect(metadata.player_url).to eq('https://avplayer.lib.berkeley.edu/b22139658')
      end
    end

    describe :player_link_text do
      it 'finds the player_link_text' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
        metadata = Metadata.for_record(record_id: 'b22139658')
        expect(metadata.player_link_text).to eq('UC Berkeley online videos. Freely available.')
      end
    end
  end
end
