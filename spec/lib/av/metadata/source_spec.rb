require 'spec_helper'

# TODO: break some of this out into a Metadata::Reader spec
module AV
  class Metadata
    describe Source do
      before(:each) do
        allow(BerkeleyLibrary::Logging).to receive(:logger).and_return(Logger.new(File::NULL))
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

        it 'returns ALMA for an Alma MMS ID' do
          expect(Source.for_record_id('991054360089706532')).to be(Source::ALMA)
        end
      end

      describe :catalog_link_text do
        it 'returns Millennium text for a Millennium record' do
          expect(Source::MILLENNIUM.catalog_link_text).to eq(Source::LINK_TEXT_MILLENNIUM)
        end

        it 'returns TIND text for a TIND record' do
          expect(Source::TIND.catalog_link_text).to eq(Source::LINK_TEXT_TIND)
        end

        it 'returns Alma text for an Alma record' do
          expect(Source::ALMA.catalog_link_text).to eq(Source::LINK_TEXT_ALMA)
        end
      end

      describe 'ALMA' do
        attr_reader :sru_url_base, :permalink_base

        before(:each) do
          AV::Config.alma_sru_host = 'berkeley.alma.exlibrisgroup.com'
          AV::Config.alma_institution_code = '01UCS_BER'
          AV::Config.alma_primo_host = 'search.library.berkeley.edu'
          AV::Config.alma_permalink_key = 'iqob43'

          @sru_url_base = 'https://berkeley.alma.exlibrisgroup.com/view/sru/01UCS_BER?version=1.2&operation=searchRetrieve&query='
          @permalink_base = 'https://search.library.berkeley.edu/permalink/01UCS_BER/iqob43/alma'
        end

        describe :marc_uri_for do
          it 'returns the search URI for an Alma MMS ID' do
            mms_id = '991054360089706532'
            url_expected = "#{sru_url_base}alma.mms_id%3D#{mms_id}"
            uri_expected = URI.parse(url_expected)
            uri_actual = Source::ALMA.marc_uri_for(mms_id)
            expect(uri_actual).to eq(uri_expected)
          end

          it 'returns the search URI for a Millennium bib number with or without check digit' do
            full_bib = 'b257169738'
            url_expected = "#{sru_url_base}alma.other_system_number%3DUCB-#{full_bib}-01ucs_ber"
            uri_expected = URI.parse(url_expected)
            aggregate_failures do
              %w[b25716973 b257169738 b25716973a].each do |bib|
                uri_actual = Source::ALMA.marc_uri_for(bib)
                expect(uri_actual).to eq(uri_expected)
              end
            end
          end
        end

        describe :display_uri_for do
          it 'returns the Primo permalink' do
            mms_id = '991054360089706532'
            marc_record = MARC::XMLReader.new("spec/data/alma/#{mms_id}-sru.xml").first
            uri_expected = URI.parse("#{permalink_base}#{mms_id}")

            metadata = Metadata.new(
              record_id: mms_id,
              source: Source::ALMA,
              marc_record: marc_record
            )

            uri_actual = Source::ALMA.display_uri_for(metadata)
            expect(uri_actual).to eq(uri_expected)
          end
        end

        describe :record_for do
          it 'loads a record from an MMS ID' do
            mms_id = '991054360089706532'
            marc_xml_path = "spec/data/alma/#{mms_id}-sru.xml"
            sru_url = "#{sru_url_base}alma.mms_id%3D#{mms_id}"
            marc_xml = File.read(marc_xml_path)
            stub_request(:get, sru_url).to_return(status: 200, body: marc_xml)

            marc_record = Source::ALMA.record_for(mms_id)
            expect(marc_record).to eq(MARC::XMLReader.new(marc_xml_path).first)
          end

          it 'loads a record from a bib number' do
            short_bib = 'b25716973'
            full_bib = RecordId.ensure_check_digit(short_bib)
            marc_xml_path = "spec/data/alma/#{short_bib}-sru.xml"
            marc_xml = File.read(marc_xml_path)
            sru_url = "#{sru_url_base}alma.other_system_number%3DUCB-#{full_bib}-01ucs_ber"
            stub_request(:get, sru_url).to_return(status: 200, body: marc_xml)

            aggregate_failures do
              %w[b25716973 b257169738 b25716973a].each do |bib|
                marc_record = Source::ALMA.record_for(bib)
                expect(marc_record).to eq(MARC::XMLReader.new(marc_xml_path).first)
              end
            end
          end
        end
      end

      describe 'MILLENNIUM' do
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

      describe 'TIND' do
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

          it 'raises ArgumentError for the wrong type of record' do
            marc_xml = File.read('spec/data/alma/b20786580-sru.xml')
            marc_record = AV::Marc.from_xml(marc_xml)

            metadata = Metadata.new(
              record_id: '(pacradio)00107',
              source: Source::ALMA,
              marc_record: marc_record
            )

            expect { Source::TIND.display_uri_for(metadata) }.to raise_error(ArgumentError)
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
