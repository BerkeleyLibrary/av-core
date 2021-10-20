require 'spec_helper'
require 'uri'
require 'ostruct'
module AV
  describe Config do

    after(:each) do
      Config.send(:clear!)
    end

    describe(:configured?) do
      it 'defaults to false' do
        expect(AV.configured?).to eq(false)
      end

      it 'returns true if and only if all values are configured' do
        settings = {
          avplayer_base_uri: 'http://avplayer.example.edu',
          alma_sru_host: 'berkeley.alma.exlibrisgroup.com',
          alma_primo_host: 'search.library.berkeley.edu',
          alma_institution_code: '01UCS_BER',
          alma_permalink_key: 'iqob43',
          millennium_base_uri: 'http://millennium.example.edu',
          tind_base_uri: 'http://tind.example.edu',
          wowza_base_uri: 'http://wowza.example.edu'
        }
        settings.each { |setting, value| Config.send("#{setting}=", value) }
        expect(AV.configured?).to eq(true)

        aggregate_failures do
          settings.each do |setting, value|
            Config.instance_variable_set("@#{setting}".to_sym, nil)
            expect(AV.configured?).to eq(false), "Clearing #{setting} did not set configured? to false"
            Config.send("#{setting}=", value)
          end
        end
      end

      it 'reads values from a Rails config if present' do
        settings = {
          avplayer_base_uri: URI.parse('http://avplayer.example.edu'),
          alma_sru_host: 'berkeley.alma.exlibrisgroup.com',
          alma_primo_host: 'search.library.berkeley.edu',
          alma_institution_code: '01UCS_BER',
          alma_permalink_key: 'iqob43',
          millennium_base_uri: URI.parse('http://millennium.example.edu'),
          tind_base_uri: URI.parse('http://tind.example.edu'),
          wowza_base_uri: URI.parse('http://wowza.example.edu')
        }
        rails_config = OpenStruct.new(settings)

        # Mock Rails config
        expect(defined?(Rails)).to be_nil # just to be sure
        Object.send(:const_set, 'Rails', OpenStruct.new)
        Rails.application = OpenStruct.new
        Rails.application.config = rails_config

        aggregate_failures do
          settings.each do |setting, v|
            expect(Config.send(setting)).to eq(v)
          end
        end

        expect(AV.configured?).to eq(true)
      ensure
        Object.send(:remove_const, 'Rails')
      end
    end

    describe(:missing) do
      it 'defaults to all settings' do
        expect(Config.missing).to eq(Config::REQUIRED_SETTINGS)
      end

      it 'returns an empty array if nothing is missing' do
        settings = {
          avplayer_base_uri: 'http://avplayer.example.edu',
          alma_sru_host: 'berkeley.alma.exlibrisgroup.com',
          alma_primo_host: 'search.library.berkeley.edu',
          alma_institution_code: '01UCS_BER',
          alma_permalink_key: 'iqob43',
          millennium_base_uri: 'http://millennium.example.edu',
          tind_base_uri: 'http://tind.example.edu',
          wowza_base_uri: 'http://wowza.example.edu'
        }
        settings.each { |setting, value| Config.send("#{setting}=", value) }

        expect(Config.missing).to eq([])
      end

      it 'returns the missing settings' do
        settings = {
          avplayer_base_uri: 'http://avplayer.example.edu',
          alma_sru_host: 'berkeley.alma.exlibrisgroup.com',
          alma_primo_host: 'search.library.berkeley.edu',
          alma_institution_code: '01UCS_BER',
          alma_permalink_key: 'iqob43',
          millennium_base_uri: 'http://millennium.example.edu',
          tind_base_uri: 'http://tind.example.edu',
          wowza_base_uri: 'http://wowza.example.edu'
        }
        settings.each { |setting, value| Config.send("#{setting}=", value) }

        expected = []
        settings.each_key do |setting|
          Config.instance_variable_set("@#{setting}".to_sym, nil)
          expected << setting
          expect(Config.missing).to eq(expected)
        end
      end
    end

    describe :avplayer_base_uri= do
      it 'converts strings to URIs' do
        expected_uri = URI.parse('http://avplayer.example.edu')
        Config.avplayer_base_uri = expected_uri.to_s
        expect(Config.avplayer_base_uri).to eq(expected_uri)
      end

      it 'strips trailing slashes' do
        expected_uri = URI.parse('http://avplayer.example.edu')
        Config.avplayer_base_uri = "#{expected_uri}/"
        expect(Config.avplayer_base_uri).to eq(expected_uri)
      end
    end

    describe :alma_sru_host= do
      it 'sets the hostname' do
        expected_host = 'alma.example.org'
        Config.alma_sru_host = expected_host
        expect(Config.alma_sru_host).to eq(expected_host)
        expect(Config.alma_sru_base_uri.host).to eq(expected_host)
      end
    end

    describe :millennium_base_uri= do
      it 'converts strings to URIs' do
        expected_uri = URI.parse('http://millennium.example.edu')
        Config.millennium_base_uri = expected_uri.to_s
        expect(Config.millennium_base_uri).to eq(expected_uri)
      end

      it 'strips trailing slashes' do
        expected_uri = URI.parse('http://millennium.example.edu')
        Config.millennium_base_uri = "#{expected_uri}/"
        expect(Config.millennium_base_uri).to eq(expected_uri)
      end
    end

    describe :wowza_base_uri= do
      it 'converts strings to URIs' do
        expected_uri = URI.parse('http://wowza.example.edu')
        Config.wowza_base_uri = expected_uri.to_s
        expect(Config.wowza_base_uri).to eq(expected_uri)
      end

      it 'strips trailing slashes' do
        expected_uri = URI.parse('http://wowza.example.edu')
        Config.wowza_base_uri = "#{expected_uri}/"
        expect(Config.wowza_base_uri).to eq(expected_uri)
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
        Config.tind_base_uri = "#{expected_uri}/"
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

      describe :avplayer_base_uri do
        attr_reader :avplayer_base_uri

        before(:each) do
          @avplayer_base_uri = URI.parse('http://avplayer.example.edu')
          allow(config).to receive(:avplayer_base_uri).and_return(avplayer_base_uri.to_s)
        end

        it 'falls back to the Rails config, if available' do
          expect(Config.avplayer_base_uri).to eq(avplayer_base_uri)
        end

        it 'prefers the explicitly configured URI' do
          expected_avplayer_uri = URI.parse('https://avplayer-other.example.edu')
          Config.avplayer_base_uri = expected_avplayer_uri
          expect(Config.avplayer_base_uri).to eq(expected_avplayer_uri)
        end
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
