require 'berkeley_library/util/uris'

require 'av/config'
require 'av/metadata/readers/xml_base'

module AV
  class Metadata
    module Readers
      module Alma
        include XmlBase

        def marc_uri_for(record_id)
          rec_id = ensure_valid_id(record_id)

          query_value = if rec_id.type == RecordId::Type::ALMA
            'alma.mms_id=' + record_id
          elsif rec_id.type == RecordId::Type::MILLENNIUM
            bib_number = RecordId.ensure_check_digit(rec_id.id)
            'alma.other_system_number=UCB-' + bib_number + AV::Config.alma_institution_code.downcase
          end

          query_string = URI.encode_www_form(
            'version' => '1.2',
            'operation' => 'searchRetrieve',
            'query' => query_value
          )

          URIs.append(base_uri, '?', query_string)
        end

        private

        def base_uri
          AV::Config.alma_sru_base_uri
        end

      end
    end
  end
end
