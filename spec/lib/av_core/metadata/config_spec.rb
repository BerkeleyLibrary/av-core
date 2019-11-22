require 'spec_helper'
require 'av_core/metadata'
require 'uri'

module AVCore
  module Metadata
    describe Config do

      after(:each) do
        Config.instance_variable_set(:@millennium_base_uri, nil)
        Config.instance_variable_set(:@tind_base_uri, nil)
      end

      describe :base_uri_for do
        it 'returns the configured Millennium URL' do
          expected_uri = URI.parse('http://millennium.example.edu')
          Config.millennium_base_uri = expected_uri
          expect(Config.base_uri_for(Source::MILLENNIUM)).to eq(expected_uri)
        end

        it 'returns the configured Tind URL' do
          expected_uri = URI.parse('http://tind.example.edu')
          Config.tind_base_uri = expected_uri
          expect(Config.base_uri_for(Source::TIND)).to eq(expected_uri)
        end

        it 'rejects an unknown source' do
          source = instance_double(Source)
          expect { Config.base_uri_for(source) }.to raise_error(ArgumentError)
        end
      end

      describe :millennium_base_uri= do
        it 'converts strings to URIs' do
          expected_uri = URI.parse('http://millennium.example.edu')
          Config.millennium_base_uri = expected_uri.to_s
          expect(Config.base_uri_for(Source::MILLENNIUM)).to eq(expected_uri)
        end

        it 'strips trailing slashes' do
          expected_uri = URI.parse('http://millennium.example.edu')
          Config.millennium_base_uri = expected_uri.to_s + '/'
          expect(Config.base_uri_for(Source::MILLENNIUM)).to eq(expected_uri)
        end

      end

      describe 'with Rails config' do
        attr_reader :config

        before(:each) do
          @config = double(Config)

          application = double(Object)
          allow(application).to receive(:config).and_return(config)

          rails = double(Object)
          allow(rails).to receive(:application).and_return(application)

          Object.const_set(:Rails, rails)
        end

        after(:each) do
          Object.send(:remove_const, :Rails)
        end

        describe :base_uri_for do
          attr_reader :millennium_base_uri
          attr_reader :tind_base_uri

          before(:each) do
            @millennium_base_uri = URI.parse('http://millennium.example.edu')
            allow(config).to receive(:millennium_base_uri).and_return(millennium_base_uri.to_s)
            @tind_base_uri = URI.parse('http://tind.example.edu')
            allow(config).to receive(:tind_base_uri).and_return(tind_base_uri.to_s)
          end

          it 'falls back to the Rails config, if available' do
            expect(Config.base_uri_for(Source::MILLENNIUM)).to eq(millennium_base_uri)
            expect(Config.base_uri_for(Source::TIND)).to eq(tind_base_uri)
          end

          it 'prefers the explicitly configured URI' do
            expected_millennium_uri = URI.parse('https://millennium-other.example.edu')
            Config.millennium_base_uri = expected_millennium_uri
            expect(Config.base_uri_for(Source::MILLENNIUM)).to eq(expected_millennium_uri)

            expected_tind_uri = URI.parse('https://tind-other.example.edu')
            Config.tind_base_uri = expected_tind_uri
            expect(Config.base_uri_for(Source::TIND)).to eq(expected_tind_uri)
          end
        end
      end
    end
  end
end
