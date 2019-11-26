require 'rest_client'
require 'typesafe_enum'
require 'av_core/logger'

module AVCore
  module Metadata
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

      def base_uri
        Config.base_uri_for(self)
      end

      class << self
        def millennium_record_for(bib_number)
          # noinspection RubyResolve
          url = "#{MILLENNIUM.base_uri}?/.#{bib_number}/.#{bib_number}/1%2C1%2C1%2CB/marc~#{bib_number}"
          html = do_get(url).scrub
          MillenniumMARCExtractor.new(html).extract_marc_record
        rescue StandardError => e
          raise RecordNotFound, "Can't find Millennium record for bib number #{bib_number.inspect}: #{e.message}"
        end

        def tind_record_for(tind_id)
          record = begin
            # noinspection RubyResolve
            url = "#{TIND.base_uri}/record/#{tind_id}/export/xm"
            xml = do_get(url).scrub
            input = StringIO.new(xml)
            MARC::XMLReader.new(input).first
          rescue StandardError => e
            raise RecordNotFound, "Can't find TIND record for record ID #{tind_id.inspect}: #{e.message}"
          end
          return record if record

          raise RecordNotFound, "No record returned for TIND ID #{tind_id.inspect}"
        end

        private

        def log
          AVCore.logger
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
