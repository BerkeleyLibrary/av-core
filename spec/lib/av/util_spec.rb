require 'spec_helper'

module AV
  describe Util do
    describe :do_get do
      it 'sends a custom user-agent header' do
        expected_ua = Util::DEFAULT_USER_AGENT

        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).with(headers: { 'User-Agent' => expected_ua }).to_return(status: 200, body: body)

        uri = URI.parse(url)
        result = AV::Util.do_get(uri)
        expect(result).to eq(body.scrub)
      end

      it 'ignores errors if ignore_errors is set to true' do
        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        stub_request(:get, url).to_return(status: 404)
        uri = URI.parse(url)
        result = AV::Util.do_get(uri, ignore_errors: true)
        expect(result).to be_nil
      end
    end
  end
end
