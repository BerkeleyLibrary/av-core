require 'spec_helper'
require 'av/logger'
require 'av/metadata/source'
require 'av/record_not_found'

module AV
  class Metadata
    describe Source do
      attr_reader :logger_orig

      before(:each) do
        @logger_orig = AV.instance_variable_get(:@logger)
        AV.instance_variable_set(:@logger, Logger.new(File::NULL))
      end

      after(:each) do
        AV.instance_variable_set(:@logger, logger_orig)
      end

      describe :base_uri_for do
        it 'raises ArgumentError for unconfigured sources' do
          source = Source.allocate
          expect { source.base_uri }.to raise_error(ArgumentError)
        end
      end

      describe :record_for do
        it 'raises NoMethodError for unconfigured sources' do
          source = Source.allocate
          expect { source.record_for('Lot 49') }.to raise_error(NoMethodError)
        end
      end

      describe Source::MILLENNIUM do
        attr_reader :search_url

        before(:each) do
          AV::Config.millennium_base_uri = 'http://oskicat.berkeley.edu/search~S1'
          @search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        end

        after(:each) do
          AV::Config.instance_variable_set(:@millennium_base_uri, nil)
        end

        describe :record_for do
          it 'finds a MARC record' do
            marc_html = File.read('spec/data/b22139658.html')
            stub_request(:get, search_url).to_return(status: 200, body: marc_html)

            marc_record = Source::MILLENNIUM.record_for('b22139658')
            title = marc_record['245']
            expect(title['a']).to eq('Communists on campus')
            expect(title['h']).to eq('[electronic resource] /')
            expect(title['c']).to eq('presented by the National Education Program, Searcy, Arkansas ; writer and producer, Sidney O. Fields.')

            expected_summary = <<~TEXT
              An American propaganda documentary created "to inform and
              impress on American citizens the true nature and the true
              magnitude of those forces that are working within our
              nation for its overthrow...and the destruction of our
              educational system." Film covers the July 1969 California
              Revolutionary Conference and other demonstrations, warning
              against the activities of Students for a Democratic
              Society, the Black Panthers, student protestors and
              Vietnam War demonstrators as they promote a "socialist/
              communist overthrow of the U.S. government," taking as
              their mentor Chairman Mao Tse-Tung.
            TEXT
            expected_summary = expected_summary.gsub("\n", ' ').strip

            summary = marc_record['520']
            expect(summary['a']).to eq(expected_summary)

            personal_names = marc_record.fields('700')
            expect(personal_names.size).to eq(27)
          end

          it "raises #{AV::RecordNotFound} if the record cannot be found" do
            stub_request(:get, search_url).to_return(status: 404, body: '')

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if the record cannot be parsed" do
            stub_request(:get, search_url).to_return(status: 200, body: 'Something that is not a Millennium MARC HTML page')

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if Millennium returns a weird HTTP status" do
            marc_html = File.read('spec/data/b22139658.html')
            stub_request(:get, search_url).to_return(status: 207, body: marc_html)

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end
        end
      end

      describe Source::TIND do
        attr_reader :search_url

        before(:each) do
          AV::Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
          @search_url = 'https://digicoll.lib.berkeley.edu/record/19816/export/xm'
        end

        after(:each) do
          AV::Config.instance_variable_set(:@tind_base_uri, nil)
        end

        describe :record_for do
          it 'finds a MARC record' do
            marc_xml = File.read('spec/data/record-19816.xml')
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

            marc_record = Source::TIND.record_for('19816')
            expect(marc_record).not_to be_nil
            expect(marc_record).to be_a(MARC::Record)

            fields_001 = marc_record.fields('001')
            expect(fields_001.size).to eq(1)
            expect(fields_001[0].value).to eq('19816')
          end

          it "raises #{AV::RecordNotFound} if the record cannot be found" do
            stub_request(:get, search_url).to_return(status: 404, body: '')

            expect { Source::TIND.record_for('19816') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if the record cannot be parsed" do
            stub_request(:get, search_url).to_return(status: 200, body: '<? this is not valid MARCXML>')

            expect { Source::TIND.record_for('19816') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if no records are returned" do
            empty_result = File.read('spec/data/record-empty-result.xml')
            stub_request(:get, search_url).to_return(status: 200, body: empty_result)

            expect { Source::TIND.record_for('19816') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} on a redirect to login" do
            redirect_to_login = File.read('spec/data/record-redirect-to-login.html')
            stub_request(:get, search_url).to_return(status: 200, body: redirect_to_login)

            expect { Source::TIND.record_for('19816') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if TIND returns a weird HTTP status" do
            marc_xml = File.read('spec/data/record-19816.xml')
            stub_request(:get, search_url).to_return(status: 207, body: marc_xml)

            expect { Source::TIND.record_for('19816') }.to raise_error(AV::RecordNotFound)
          end
        end
      end
    end
  end
end
