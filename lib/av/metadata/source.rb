require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/logger'
require 'av/record_not_found'
require 'av/marc/millennium'

module AV
  class Metadata
    class Source < TypesafeEnum::Base
      new :TIND do
        def record_for(tind_id)
          Source.tind_record_for(tind_id)
        end
      end

      new :MILLENNIUM do
        def record_for(bib_number)
          Source.millennium_record_for(bib_number)
        end
      end

      def record_for(_record_id)
        raise NoMethodError, "Source class #{self.class} must override Source.record_for"
      end

      def base_uri
        return AV::Config.millennium_base_uri if self == Source::MILLENNIUM
        return AV::Config.tind_base_uri if self == Source::TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      class << self

        # Gets a MARC record from Millennium.
        #
        # @param bib_number [String] the bib number
        # @return [MARC::Record] the MARC record for the specified bib number
        def millennium_record_for(bib_number)
          # noinspection RubyResolve
          url = "#{MILLENNIUM.base_uri}?/.#{bib_number}/.#{bib_number}/1%2C1%2C1%2CB/marc~#{bib_number}"
          html = do_get(url).scrub
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
            # noinspection RubyResolve
            url = "#{TIND.base_uri}/record/#{tind_id}/export/xm"
            xml = do_get(url).scrub
            input = StringIO.new(xml)
            MARC::XMLReader.new(input).first
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

        def do_get(url)
          log.debug("GET #{url}")

          resp = RestClient.get(url)
          if resp.code != 200
            log.error("GET #{url} returned #{resp.code}: #{resp.body || 'nil'}")
            raise(RestClient::RequestFailed.new(resp, resp.code).tap do |ex|
              ex.message = "No record found at #{url}; host returned #{resp.code}"
            end)
          end
          resp.body
        end
      end
    end
  end
end
