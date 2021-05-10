require 'spec_helper'

# TODO: break some of this out into a Metadata::Reader spec
module AV
  class Metadata
    describe Source do
      before(:each) do
        allow(UCBLIT::Logging).to receive(:logger).and_return(Logger.new(File::NULL))
      end

      describe :for_record_id do
        it 'returns MILLENNIUM for a Millennium bib number' do
          expect(Source.for_record_id('b12345678')).to be(Source::MILLENNIUM)
        end

        it 'returns MILLENNIUM for a Millennium bib number with check digit' do
          expect(Source.for_record_id('b12345678a')).to be(Source::MILLENNIUM)
        end

        it "returns TIND for something that looks a little like a Millennium bib but isn't" do
          expect(Source.for_record_id('b1234567')).to be(Source::TIND)
          expect(Source.for_record_id('b123456789abcdef')).to be(Source::TIND)
        end

        it 'returns TIND for a TIND record number' do
          expect(Source.for_record_id('(coll)12345')).to be(Source::TIND)
        end

        it 'returns TIND for an OCLC number' do
          expect(Source.for_record_id('o12345678')).to be(Source::TIND)
        end
      end

      describe :catalog_link_text do
        it 'returns Millennium text for a Millennium record' do
          expect(Source::MILLENNIUM.catalog_link_text).to eq(Source::LINK_TEXT_MILLENNIUM)
        end

        it 'returns TIND text for a TIND record' do
          expect(Source::TIND.catalog_link_text).to eq(Source::LINK_TEXT_TIND)
        end

        it 'raises an error for an unknown source' do
          source = Source.allocate
          expect { source.catalog_link_text }.to raise_error(ArgumentError)
        end
      end

      describe :_reader do
        it 'returns Millennium reader for a Millennium source' do
          expect(Source::MILLENNIUM._reader).to be(Readers::Millennium)
        end

        it 'returns TIND reader for a TIND record' do
          expect(Source::TIND._reader).to be(Readers::TIND)
        end
        it 'raises an error for an unknown source' do
          source = Source.allocate
          expect { source._reader }.to raise_error(ArgumentError)
        end
      end

      describe Source::MILLENNIUM do
        attr_reader :record_url

        before(:each) do
          AV::Config.millennium_base_uri = 'http://oskicat.berkeley.edu/'
          @record_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        end

        after(:each) do
          AV::Config.instance_variable_set(:@millennium_base_uri, nil)
        end

        describe :marc_uri_for do
          it 'returns the search URI' do
            uri_expected = URI.parse(record_url)
            uri_actual = Source::MILLENNIUM.marc_uri_for('b22139658')
            expect(uri_actual).to eq(uri_expected)
          end

          it 'raises ArgumentError for a non-Millennium ID' do
            expect { Source::MILLENNIUM.marc_uri_for('19816') }.to raise_error(ArgumentError)
          end
        end

        describe :display_uri_for do
          it 'returns the record display page URI' do
            marc_html = File.read('spec/data/b22139658.html')
            stub_request(:get, record_url).to_return(status: 200, body: marc_html)

            metadata = Metadata.new(
              record_id: 'b22139658',
              source: Source::MILLENNIUM,
              marc_record: Source::MILLENNIUM.record_for('b22139658')
            )

            uri_expected = URI.parse('http://oskicat.berkeley.edu/record=b22139658')
            uri_actual = Source::MILLENNIUM.display_uri_for(metadata)
            expect(uri_actual).to eq(uri_expected)
          end

          it 'raises ArgumentError for a non-Millennium ID' do
            expect { Source::MILLENNIUM.display_uri_for('19816') }.to raise_error(ArgumentError)
          end
        end

        describe :record_for do
          it 'raises ArgumentError for a non-Millennium ID' do
            expect { Source::MILLENNIUM.record_for('19816') }.to raise_error(ArgumentError)
          end

          it 'finds a MARC record' do
            marc_html = File.read('spec/data/b22139658.html')
            stub_request(:get, record_url).to_return(status: 200, body: marc_html)

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
            stub_request(:get, record_url).to_return(status: 404, body: '')

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if the record cannot be parsed" do
            stub_request(:get, record_url).to_return(status: 200, body: 'Something that is not a Millennium MARC HTML page')

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if Millennium returns a weird HTTP status" do
            marc_html = File.read('spec/data/b22139658.html')
            stub_request(:get, record_url).to_return(status: 207, body: marc_html)

            expect { Source::MILLENNIUM.record_for('b22139658') }.to raise_error(AV::RecordNotFound)
          end
        end
      end

      describe Source::TIND do
        attr_reader :record_url

        before(:each) do
          AV::Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
          @record_url = 'https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22%28pacradio%2900107%22&of=xm'
        end

        after(:each) do
          AV::Config.instance_variable_set(:@tind_base_uri, nil)
        end

        describe :marc_uri_for do
          it 'returns the search URI' do
            uri_expected = URI.parse(record_url)
            uri_actual = Source::TIND.marc_uri_for('(pacradio)00107')
            expect(uri_actual).to eq(uri_expected)
          end
        end

        describe :display_uri_for do
          it 'returns the record display page URI' do
            marc_xml = File.read('spec/data/record-(pacradio)00107.xml')
            stub_request(:get, record_url).to_return(status: 200, body: marc_xml)

            metadata = Metadata.new(
              record_id: '(pacradio)00107',
              source: Source::TIND,
              marc_record: Source::TIND.record_for('(pacradio)00107')
            )

            uri_expected = URI.parse('https://digicoll.lib.berkeley.edu/record/19816')
            uri_actual = Source::TIND.display_uri_for(metadata)
            expect(uri_actual).to eq(uri_expected)
          end

          it 'raises ArgumentError for a non-TIND ID' do
            expect { Source::TIND.display_uri_for('b22139658') }.to raise_error(ArgumentError)
          end
        end

        describe :record_for do
          it 'finds a MARC record' do
            marc_xml = File.read('spec/data/record-(pacradio)00107.xml')
            stub_request(:get, record_url).to_return(status: 200, body: marc_xml)

            marc_record = Source::TIND.record_for('(pacradio)00107')
            expect(marc_record).not_to be_nil
            expect(marc_record).to be_a(MARC::Record)

            fields_001 = marc_record.fields('001')
            expect(fields_001.size).to eq(1)
            expect(fields_001[0].value).to eq('19816')
          end

          it "raises #{AV::RecordNotFound} if the record cannot be found" do
            stub_request(:get, record_url).to_return(status: 404, body: '')

            expect { Source::TIND.record_for('(pacradio)00107') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if the record cannot be parsed" do
            stub_request(:get, record_url).to_return(status: 200, body: '<? this is not valid MARCXML>')

            expect { Source::TIND.record_for('(pacradio)00107') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if no records are returned" do
            empty_result = File.read('spec/data/record-empty-result.xml')
            stub_request(:get, record_url).to_return(status: 200, body: empty_result)

            expect { Source::TIND.record_for('(pacradio)00107') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} on a redirect to login" do
            redirect_to_login = File.read('spec/data/record-redirect-to-login.html')
            stub_request(:get, record_url).to_return(status: 200, body: redirect_to_login)

            expect { Source::TIND.record_for('(pacradio)00107') }.to raise_error(AV::RecordNotFound)
          end

          it "raises #{AV::RecordNotFound} if TIND returns a weird HTTP status" do
            marc_xml = File.read('spec/data/record-(pacradio)00107.xml')
            stub_request(:get, record_url).to_return(status: 207, body: marc_xml)

            expect { Source::TIND.record_for('(pacradio)00107') }.to raise_error(AV::RecordNotFound)
          end
        end

      end
    end
  end
end
