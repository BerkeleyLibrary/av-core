require 'spec_helper'

module AV
  describe Metadata do
    describe :title do

      before(:each) do
        AV::Config.millennium_base_uri = 'http://oskicat.berkeley.edu/'
      end

      after(:each) do
        AV::Config.instance_variable_set(:@millennium_base_uri, nil)
      end

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

    describe :for_record do
      it "raises #{AV::RecordNotFound} for an ID with indeterminate source" do
        expect do
          Metadata.for_record(record_id: 'abcdefg')
        end.to raise_error(AV::RecordNotFound)
      end
    end
  end
end
