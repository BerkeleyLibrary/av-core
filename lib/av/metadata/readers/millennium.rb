require 'av/config'
require 'av/util'
require 'av/record_not_found'

module AV
  class Metadata
    module Readers
      module Millennium
        include AV::Util

        # @return [MARC::Record] the MARC record
        def record_for(record_id)
          ensure_valid_id(record_id)
          marc_uri = marc_uri_for(record_id)
          begin
            html = do_get(marc_uri)
            AV::Marc::Millennium.marc_from_html(html)
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find Millennium record for bib number #{record_id.inspect} at MARC URI #{marc_uri}: #{e.message}"
          end
        end

        def marc_uri_for(record_id)
          ensure_valid_id(record_id)
          URI.join(base_uri, "search~S1?/.#{record_id}/.#{record_id}/1%2C1%2C1%2CB/marc~#{record_id}")
        end

        def _display_uri_for(record_id)
          ensure_valid_id(record_id)
          URI.join(base_uri, "record=#{record_id}")
        end

        private

        def base_uri
          AV::Config.millennium_base_uri
        end
      end

    end
  end
end
