require 'spec_helper'
require 'uri'
require 'av/config'

module AV
  describe Config do

    after(:each) do
      Config.instance_variable_set(:@millennium_base_uri, nil)
      Config.instance_variable_set(:@tind_base_uri, nil)
    end

    describe :millennium_base_uri= do
      it 'converts strings to URIs' do
        expected_uri = URI.parse('http://millennium.example.edu')
        Config.millennium_base_uri = expected_uri.to_s
        expect(Config.millennium_base_uri).to eq(expected_uri)
      end

      it 'strips trailing slashes' do
        expected_uri = URI.parse('http://millennium.example.edu')
        Config.millennium_base_uri = expected_uri.to_s + '/'
        expect(Config.millennium_base_uri).to eq(expected_uri)
      end
    end

    describe :tind_base_uri= do
      it 'converts strings to URIs' do
        expected_uri = URI.parse('http://tind.example.edu')
        Config.tind_base_uri = expected_uri.to_s
        expect(Config.tind_base_uri).to eq(expected_uri)
      end

      it 'strips trailing slashes' do
        expected_uri = URI.parse('http://tind.example.edu')
        Config.tind_base_uri = expected_uri.to_s + '/'
        expect(Config.tind_base_uri).to eq(expected_uri)
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

      describe :millennium_base_uri do
        attr_reader :millennium_base_uri
        before(:each) do
          @millennium_base_uri = URI.parse('http://millennium.example.edu')
          allow(config).to receive(:millennium_base_uri).and_return(millennium_base_uri.to_s)
        end

        it 'falls back to the Rails config, if available' do
          expect(Config.millennium_base_uri).to eq(millennium_base_uri)
        end

        it 'prefers the explicitly configured URI' do
          expected_millennium_uri = URI.parse('https://millennium-other.example.edu')
          Config.millennium_base_uri = expected_millennium_uri
          expect(Config.millennium_base_uri).to eq(expected_millennium_uri)
        end
      end

      describe :tind_base_uri do
        attr_reader :tind_base_uri

        before(:each) do
          @tind_base_uri = URI.parse('http://tind.example.edu')
          allow(config).to receive(:tind_base_uri).and_return(tind_base_uri.to_s)
        end

        it 'falls back to the Rails config, if available' do
          expect(Config.tind_base_uri).to eq(tind_base_uri)
        end

        it 'prefers the explicitly configured URI' do
          expected_tind_uri = URI.parse('https://tind-other.example.edu')
          Config.tind_base_uri = expected_tind_uri
          expect(Config.tind_base_uri).to eq(expected_tind_uri)
        end
      end
    end
  end
end