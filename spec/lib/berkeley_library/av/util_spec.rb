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

        it 'includes authorization header for TIND requests if LIT_TIND_API_KEY is set' do
          expected_ua = Util::DEFAULT_USER_AGENT
          expected_auth = 'Token some-long-api-token-value'

          # expect do_get to call URIs.get with the correct headers
          # but we don't need to actually perform the request
          allow(BerkeleyLibrary::Util::URIs).to receive(:get).and_return('<response></response>')
          allow(AV::Config).to receive(:tind_base_uri).and_return(URI('https://tind.example.edu/'))
          url = "#{AV::Config.tind_base_uri}/some/api/endpoint"
          ENV['LIT_TIND_API_KEY'] = 'some-long-api-token-value'
          AV::Util.do_get(url)
          expect(BerkeleyLibrary::Util::URIs).to have_received(:get).with(url, headers: { user_agent: expected_ua, authorization: expected_auth })
        end

        it 'does not include authorization header for non-TIND requests' do
          expected_ua = Util::DEFAULT_USER_AGENT

          # expect do_get to call URIs.get with the correct headers
          # but we don't need to actually perform the request
          allow(BerkeleyLibrary::Util::URIs).to receive(:get).and_return('<response></response>')
          url = URI('https://alma.example.edu/some/api/endpoint')
          ENV['LIT_TIND_API_KEY'] = nil
          AV::Util.do_get(url)
          expect(BerkeleyLibrary::Util::URIs).to have_received(:get).with(url, headers: { user_agent: expected_ua })
        end
      end
    end
  end
end
