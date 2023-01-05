require 'spec_helper'

module BerkeleyLibrary
  module AV
    describe Util do
      describe :do_get do

        it 'sends a custom user-agent header' do
          expected_ua = Util::DEFAULT_USER_AGENT

          bib_number = 'b11082434'
          url = alma_sru_url_for(bib_number)
          data_path = alma_sru_data_path_for(bib_number)
          body = File.read(data_path)
          stub_request(:get, url).with(headers: { 'User-Agent' => expected_ua }).to_return(status: 200, body:)

          result = AV::Util.do_get(url)
          expect(result).to eq(body.scrub)
        end

        it 'ignores errors if ignore_errors is set to true' do
          url = alma_sru_url_for('b11082434')
          stub_request(:get, url).to_return(status: 404)
          result = AV::Util.do_get(url, ignore_errors: true)
          expect(result).to be_nil
        end
      end
    end
  end
end
