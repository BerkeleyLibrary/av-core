require 'spec_helper'

module BerkeleyLibrary
  module AV
    describe Metadata do

      before do
        Config.avplayer_base_uri = 'https://avplayer.lib.berkeley.edu'
        Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
        Config.alma_sru_host = 'berkeley.alma.exlibrisgroup.com'
        Config.alma_institution_code = '01UCS_BER'
        Config.alma_primo_host = 'search.library.berkeley.edu'
        Config.alma_permalink_key = 'iqob43'
      end

      after do
        Config.send(:clear!)
      end

      describe :title do
        it 'finds the title' do
          stub_sru_request('b22139658')
          metadata = Metadata.for_record(record_id: 'b22139658')
          expect(metadata.title).to eq('Communists on campus')
        end

        it 'returns UNKNOWN_TITLE if the title cannot be found' do
          marc_record = alma_marc_record_for('b22139658')
          marc_record.fields.delete_if { |f| f.tag == AV::Constants::TAG_TITLE_FIELD }
          metadata = Metadata.new(record_id: 'b22139658', source: AV::Metadata::Source::ALMA, marc_record:)
          expect(metadata.title).to eq(Metadata::UNKNOWN_TITLE)
        end

        it 'collapses spaces after hyphens' do
          bib_number = 'b22139647'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.title).to eq('Europe and the nuclear arms race, with David Owen and co-host Prof. Thomas Barnes')
        end
      end

      describe :calnet_or_ip? do
        it 'detects restricted audio' do
          bib_number = 'b18538031'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
        end

        it 'detects restricted video' do
          bib_number = 'b25207857'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
        end

        it 'detects CalNet restrictions' do
          bib_number = 'b24659129'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
        end

        it 'detects unrestricted audio' do
          bib_number = 'b23161018'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(false)
        end
      end

      # TODO: do we need to check the 799s?
      context 'restrictions' do
        it 'returns "UCB access"' do
          bib_number = 'b18538031'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
        end

        it 'finds "UCB Access" (capitalized)' do
          bib_number = 'b25716973'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(false)
        end

        it 'returns "Requires CalNet"' do
          bib_number = 'b24659129'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(true)
        end

        it 'returns "Freely available" for unrestricted audio' do
          bib_number = 'b23161018'
          stub_sru_request(bib_number)
          metadata = Metadata.for_record(record_id: bib_number)
          expect(metadata.calnet_or_ip?).to be(false)
          expect(metadata.calnet_only?).to be(false)
        end

        it 'extracts UCB restrictions from a TIND 856' do
          marc_record = MARC::XMLReader.new('spec/data/record-(cityarts)00002.xml').first
          metadata = Metadata.new(record_id: 'record-(cityarts)00002', source: Metadata::Source::TIND, marc_record:)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(false)
        end

        it 'extracts UCB restrictions from an Alma 956' do
          marc_record = MARC::XMLReader.new('spec/data/alma/991054360089706532-sru.xml').first
          metadata = Metadata.new(record_id: '991047179369706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(false)
        end

        it 'extracts CalNet restrictions from an Alma 956' do
          marc_record = MARC::XMLReader.new('spec/data/alma/991047179369706532-sru.xml').first
          metadata = Metadata.new(record_id: '991054360089706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(true)
        end

        it 'extracts restrictions from a 998$r' do
          marc_record = MARC::XMLReader.new('spec/data/alma/991005939359706532-sru.xml').first
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(false) # just to be sure
          expect(metadata.calnet_only?).to be(false) # just to be sure

          marc_record['998'].append(MARC::Subfield.new('r', 'UCB access. Requires CalNet.'))
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(true)
        end

        it 'extracts restrictions from multiple subfields 998$r' do
          marc_record = MARC::XMLReader.new('spec/data/alma/991005939359706532-sru.xml').first
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(false) # just to be sure
          expect(metadata.calnet_only?).to be(false) # just to be sure

          marc_record['998'].append(MARC::Subfield.new('r', 'UCB access.'))
          marc_record['998'].append(MARC::Subfield.new('r', 'Requires CalNet.'))
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(true)
          expect(metadata.calnet_only?).to be(true)
        end

        it 'accepts "CalNet" anywhere in the 998$r' do
          marc_record = MARC::XMLReader.new('spec/data/alma/991005939359706532-sru.xml').first
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_or_ip?).to be(false) # just to be sure
          expect(metadata.calnet_only?).to be(false) # just to be sure

          marc_record['998'].append(MARC::Subfield.new('r', 'some string with CalNet in it somewhere'))
          metadata = Metadata.new(record_id: '991005939359706532', source: Metadata::Source::ALMA, marc_record:)
          expect(metadata.calnet_only?).to be(true)
          expect(metadata.calnet_or_ip?).to be(false) # just to be sure
        end
      end

      describe :values do

        describe 'catalog link injection' do

          it 'injects the catalog URL if not present' do
            bib_number = 'b22139658'
            stub_sru_request(bib_number)
            metadata = Metadata.for_record(record_id: bib_number)

            catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
            expected_links = [
              Metadata::Link.new(
                url: 'https://search.library.berkeley.edu/permalink/01UCS_BER/iqob43/alma991010948099706532',
                body: AV::Metadata::Source::ALMA.catalog_link_text
              )
            ]
            expect(catalog_value.entries).to match_array(expected_links)
          end

          it 'injects a TIND URL if not present (1/2)' do
            tind_035 = '(miscmat)00615'
            marc_xml = File.read("spec/data/record-#{tind_035}.xml")
            search_url = "https://digicoll.lib.berkeley.edu/api/v1/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&format=xml"
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
            metadata = Metadata.for_record(record_id: tind_035)

            catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
            expected_links = [
              Metadata::Link.new(
                url: 'https://digicoll.lib.berkeley.edu/record/22513',
                body: Metadata::Source::TIND.catalog_link_text
              )
            ]
            expect(catalog_value.entries).to match_array(expected_links)
          end

          it 'injects a TIND URL if not present (2/2)' do
            tind_035 = 'physcolloquia-bk00169017b'
            marc_xml = File.read("spec/data/record-#{tind_035}.xml")
            search_url = "https://digicoll.lib.berkeley.edu/api/v1/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&format=xml"
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
            metadata = Metadata.for_record(record_id: tind_035)

            catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
            expected_links = [
              Metadata::Link.new(
                url: 'https://digicoll.lib.berkeley.edu/record/21937',
                body: Metadata::Source::TIND.catalog_link_text
              )
            ]
            expect(catalog_value.entries).to match_array(expected_links)
          end

          # TODO: suppress these?
          it 'works for TIND records with OskiCat URLs' do
            tind_035 = '(pacradio)00107'
            marc_xml = File.read("spec/data/record-#{tind_035}.xml")
            search_url = "https://digicoll.lib.berkeley.edu/api/v1/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&format=xml"
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
            metadata = Metadata.for_record(record_id: tind_035)

            catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
            expected_links = [
              Metadata::Link.new(
                url: 'http://oskicat.berkeley.edu/record=b23305516',
                body: 'View library catalog record.'
              ),
              Metadata::Link.new(
                url: 'https://digicoll.lib.berkeley.edu/record/19816',
                body: Metadata::Source::TIND.catalog_link_text
              )
            ]
            expect(catalog_value.entries).to match_array(expected_links)
          end

          it 'works for TIND-only records' do
            tind_035 = 'physcolloquia-bk00169017b'
            marc_xml = File.read("spec/data/record-#{tind_035}.xml")
            search_url = "https://digicoll.lib.berkeley.edu/api/v1/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&format=xml"
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
            metadata = Metadata.for_record(record_id: tind_035)

            catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
            expected_links = [
              Metadata::Link.new(
                body: Metadata::Source::TIND.catalog_link_text,
                url: 'https://digicoll.lib.berkeley.edu/record/21937'
              )
            ]
            expect(catalog_value.entries).to match_array(expected_links)
          end

        end

        describe :each_value do
          it 'returns the values' do
            tind_035 = 'physcolloquia-bk00169017b'
            marc_xml = File.read("spec/data/record-#{tind_035}.xml")
            search_url = "https://digicoll.lib.berkeley.edu/api/v1/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&format=xml"
            stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
            metadata = Metadata.for_record(record_id: tind_035)

            expected_values = metadata.values_by_field.values
            actual_values = metadata.each_value.to_a
            expect(actual_values).to eq(expected_values)
          end
        end
      end
    end
  end
end
