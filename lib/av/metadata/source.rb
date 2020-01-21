require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/logger'
require 'av/record_not_found'
require 'av/marc'
require 'av/marc/millennium'

module AV
  class Metadata
    class Source < TypesafeEnum::Base
      new :TIND do
        def record_for(tind_id)
          Source.tind_record_for(tind_id)
        end

        def marc_uri_for(tind_id)
          URI.join(base_uri, "/record/#{tind_id}/export/xm")
        end

        def display_uri_for(tind_id)
          URI.join(base_uri, "/record/#{tind_id}")
        end
      end

      new :MILLENNIUM do
        def record_for(bib_number)
          Source.millennium_record_for(bib_number)
        end

        def marc_uri_for(bib_number)
          URI.join(base_uri, "search~S1?/.#{bib_number}/.#{bib_number}/1%2C1%2C1%2CB/marc~#{bib_number}")
        end

        def display_uri_for(bib_number)
          URI.join(base_uri, "record=#{bib_number}")
        end
      end

      def base_uri
        return AV::Config.millennium_base_uri if self == Source::MILLENNIUM
        return AV::Config.tind_base_uri if self == Source::TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def record_for(_record_id)
        raise NoMethodError, "Source #{self.value.inspect} must override Source.record_for"
      end

      def marc_uri_for(_record_id)
        raise NoMethodError, "Source #{self.value.inspect} must override Source.marc_uri_for"
      end

      def display_uri_for(_record_id)
        raise NoMethodError, "Source #{self.value.inspect} must override Source.display_uri_for"
      end

      class << self
        MILLENNIUM_RECORD_RE = /^b[0-9]+$/.freeze
        TIND_RECORD_RE = /^[0-9]+$/.freeze

        def for_record_id(record_id)
          return Source::MILLENNIUM if record_id =~ MILLENNIUM_RECORD_RE

          Source::TIND if record_id =~ TIND_RECORD_RE
        end

        # Gets a MARC record from Millennium.
        #
        # @param bib_number [String] the bib number
        # @return [MARC::Record] the MARC record for the specified bib number
        def millennium_record_for(bib_number)
          html = do_get(MILLENNIUM.marc_uri_for(bib_number)).scrub
          AV::Marc::Millennium.marc_from_html(html)
        rescue StandardError => e
          raise AV::RecordNotFound, "Can't find Millennium record for bib number #{bib_number.inspect}: #{e.message}"
        end

        # Gets a MARC record from TIND.
        #
        # @param tind_id [String, Integer] the TIND record ID
        # @return [MARC::Record] the MARC record for the specified TIND ID
        def tind_record_for(tind_id)
          record = begin
            xml = do_get(TIND.marc_uri_for(tind_id))
            AV::Marc.from_xml(xml)
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find TIND record for record ID #{tind_id.inspect}: #{e.message}"
          end
          return record if record

          raise AV::RecordNotFound, "No record returned for TIND ID #{tind_id.inspect}"
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
    end
  end
end
