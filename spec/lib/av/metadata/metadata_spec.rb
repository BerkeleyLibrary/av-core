require 'spec_helper'

module AV
  describe Metadata do

    before(:each) do
      Config.avplayer_base_uri = 'https://avplayer.lib.berkeley.edu'
      Config.millennium_base_uri = 'http://oskicat.berkeley.edu/'
      Config.tind_base_uri = 'https://digicoll.lib.berkeley.edu'
      Config.alma_sru_host = 'berkeley.alma.exlibrisgroup.com'
      Config.alma_institution_code = '01UCS_BER'
      Config.alma_primo_host = 'search.library.berkeley.edu'
      Config.alma_permalink_key = 'iqob43'
    end

    after(:each) do
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
        metadata = Metadata.new(record_id: 'b22139658', source: AV::Metadata::Source::ALMA, marc_record: marc_record)
        expect(metadata.title).to eq(Metadata::UNKNOWN_TITLE)
      end

      it 'collapses spaces after hyphens' do
        bib_number = 'b22139647'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.title).to eq('Europe and the nuclear arms race, with David Owen and co-host Prof. Thomas Barnes')
      end
    end

    describe :ucb_access? do
      it 'detects restricted audio' do
        bib_number = 'b18538031'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(true)
      end

      it 'detects restricted video' do
        bib_number = 'b25207857'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(true)
      end

      it 'detects CalNet restrictions' do
        bib_number = 'b24659129'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(true)
      end

      it 'detects unrestricted audio' do
        bib_number = 'b23161018'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.ucb_access?).to eq(false)
      end
    end

    # TODO: do we need to check the 799s?
    describe :restrictions do
      it 'returns "UCB access"' do
        bib_number = 'b18538031'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.restrictions).to eq('UCB access')
      end

      it 'finds "UCB Access" (capitalized)' do
        bib_number = 'b25716973'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.restrictions).to eq('UCB access')
      end

      it 'returns "Requires CalNet"' do
        bib_number = 'b24659129'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.restrictions).to eq('Requires CalNet')
      end

      it 'returns "Freely available" for unrestricted audio' do
        bib_number = 'b23161018'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.restrictions).to eq('Freely available')
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
          expect(catalog_value.entries).to contain_exactly(*expected_links)
        end

        it 'injects a TIND URL if not present (1/2)' do
          tind_035 = '(miscmat)00615'
          marc_xml = File.read("spec/data/record-#{tind_035}.xml")
          search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
          stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
          metadata = Metadata.for_record(record_id: tind_035)

          catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
          expected_links = [
            Metadata::Link.new(
              url: 'https://digicoll.lib.berkeley.edu/record/22513',
              body: Metadata::Source::TIND.catalog_link_text
            )
          ]
          expect(catalog_value.entries).to contain_exactly(*expected_links)
        end

        it 'injects a TIND URL if not present (2/2)' do
          tind_035 = 'physcolloquia-bk00169017b'
          marc_xml = File.read("spec/data/record-#{tind_035}.xml")
          search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
          stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
          metadata = Metadata.for_record(record_id: tind_035)

          catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
          expected_links = [
            Metadata::Link.new(
              url: 'https://digicoll.lib.berkeley.edu/record/21937',
              body: Metadata::Source::TIND.catalog_link_text
            )
          ]
          expect(catalog_value.entries).to contain_exactly(*expected_links)
        end

        # TODO: suppress these?
        it 'works for TIND records with OskiCat URLs' do
          tind_035 = '(pacradio)00107'
          marc_xml = File.read("spec/data/record-#{tind_035}.xml")
          search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
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
          expect(catalog_value.entries).to contain_exactly(*expected_links)
        end

        it 'works for TIND-only records' do
          tind_035 = 'physcolloquia-bk00169017b'
          marc_xml = File.read("spec/data/record-#{tind_035}.xml")
          search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
          stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
          metadata = Metadata.for_record(record_id: tind_035)

          catalog_value = metadata.values_by_field[Metadata::Fields::CATALOG_LINK]
          expected_links = [
            Metadata::Link.new(
              body: Metadata::Source::TIND.catalog_link_text,
              url: 'https://digicoll.lib.berkeley.edu/record/21937'
            )
          ]
          expect(catalog_value.entries).to contain_exactly(*expected_links)
        end

      end

      describe :each_value do
        it 'returns the values' do
          tind_035 = 'physcolloquia-bk00169017b'
          marc_xml = File.read("spec/data/record-#{tind_035}.xml")
          search_url = "https://digicoll.lib.berkeley.edu/search?p=035__a%3A%22#{CGI.escape(tind_035)}%22&of=xm"
          stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
          metadata = Metadata.for_record(record_id: tind_035)

          expected_values = metadata.values_by_field.values
          actual_values = metadata.each_value.to_a
          expect(actual_values).to eq(expected_values)
        end
      end
    end

    describe :player_url do
      it 'finds the player_url' do
        bib_number = 'b22139658'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        # TODO: use ALMA record ID?
        expect(metadata.player_url).to eq('https://avplayer.lib.berkeley.edu/Video-Public-MRC/b22139658')
      end
    end

    describe :player_link_text do
      it 'finds the player_link_text' do
        bib_number = 'b22139658'
        stub_sru_request(bib_number)
        metadata = Metadata.for_record(record_id: bib_number)
        expect(metadata.player_link_text).to eq('UC Berkeley online videos. Freely available.')
      end
    end
  end
end
