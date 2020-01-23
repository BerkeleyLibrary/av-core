require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/logger'
require 'av/record_not_found'
require 'av/marc'
require 'av/marc/millennium'

module AV
  class Metadata
    # rubocop:disable Metrics/BlockLength
    class Source < TypesafeEnum::Base
      new :TIND do
        def record_for(tind_id)
          record_id = ensure_valid_id(tind_id)
          record = begin
            xml = do_get(TIND.marc_uri_for(record_id))
            AV::Marc.from_xml(xml)
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find TIND record for record ID #{record_id.inspect}: #{e.message}"
          end
          return record if record

          raise AV::RecordNotFound, "No record returned for TIND ID #{record_id.inspect}"
        end

        def record_for_bib(bib_number)
          record_id = Source::MILLENNIUM.ensure_valid_id(bib_number)

          record = begin
            marc_reader = records_for_bib(record_id)
            marc_reader && marc_reader.first
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find TIND record for record ID #{record_id.inspect}: #{e.message}"
          end
          return record if record

          raise AV::RecordNotFound, "No TIND records found for Millennium bib number #{bib_number}"
        end

        def records_for_bib(bib_number)
          record_id = Source::MILLENNIUM.ensure_valid_id(bib_number)
          search_uri = URI.join(Source::TIND.base_uri, '/search')
          search_uri.query = URI.encode_www_form('p' => "901__m:\"#{record_id}\"", 'of' => 'xm')
          xml = do_get(search_uri)
          AV::Marc.all_from_xml(xml)
        rescue StandardError => e
          raise AV::RecordNotFound, "Can't find TIND records for Millennium bib number #{bib_number}: #{e.message}"
        end

        def marc_uri_for(tind_id)
          record_id = ensure_valid_id(tind_id)
          URI.join(base_uri, "/record/#{record_id}/export/xm")
        end

        def display_uri_for(tind_id)
          record_id = ensure_valid_id(tind_id)
          URI.join(base_uri, "/record/#{record_id}")
        end
      end

      new :MILLENNIUM do
        def record_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          begin
            html = do_get(MILLENNIUM.marc_uri_for(record_id)).scrub
            AV::Marc::Millennium.marc_from_html(html)
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find Millennium record for bib number #{record_id}: #{e.message}"
          end
        end

        def marc_uri_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          URI.join(base_uri, "search~S1?/.#{record_id}/.#{record_id}/1%2C1%2C1%2CB/marc~#{record_id}")
        end

        def display_uri_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          URI.join(base_uri, "record=#{record_id}")
        end
      end

      def base_uri
        return AV::Config.millennium_base_uri if self == Source::MILLENNIUM
        return AV::Config.tind_base_uri if self == Source::TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def ensure_valid_id(record_id)
        return record_id if Source.for_record_id(record_id) == self

        raise ArgumentError, "Not a valid record ID for source #{value.inspect}: #{record_id}"
      end

      class << self
        MILLENNIUM_RECORD_RE = /^b[0-9]+$/.freeze
        TIND_RECORD_RE = /^[0-9]+$/.freeze

        def for_record_id(record_id)
          return Source::MILLENNIUM if record_id =~ MILLENNIUM_RECORD_RE

          Source::TIND if record_id =~ TIND_RECORD_RE
        end
      end

      private

      def log
        AV.logger
      end

      def do_get(uri)
        resp = RestClient.get(uri.to_s)
        if resp.code != 200
          log.error("GET #{uri} returned #{resp.code}: #{resp.body || 'nil'}")
          raise(RestClient::RequestFailed.new(resp, resp.code).tap do |ex|
            ex.message = "No record found at #{uri}; host returned #{resp.code}"
          end)
        end
        resp.body
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
