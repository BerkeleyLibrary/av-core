require 'spec_helper'

module AV
  describe Util do
    describe :log do
      it 'returns the logger' do
        expect(AV::Util.log).to be(AV.logger)
      end
    end

    describe :do_get do
      it 'accepts a string URL' do
        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).to_return(status: 200, body: body)

        result = AV::Util.do_get(url)
        expect(result).to eq(body.scrub)
      end

      it 'accepts a URI' do
        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).to_return(status: 200, body: body)

        uri = URI.parse(url)
        result = AV::Util.do_get(uri)
        expect(result).to eq(body.scrub)
      end

      it "raises #{RestClient::Exception} in the event of an invalid response" do
        aggregate_failures 'responses' do
          [207, 400, 401, 403, 404, 405, 418, 451, 500, 503].each do |code|
            url = "http://example.edu/#{code}"
            stub_request(:get, url).to_return(status: url)

            expect { AV::Util.do_get(url) }.to raise_error(RestClient::Exception)
          end
        end
      end
    end
  end
end
