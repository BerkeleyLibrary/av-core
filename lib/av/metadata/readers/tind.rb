require 'av/config'
require 'av/metadata/readers/xml_base'

module AV
  class Metadata
    module Readers
      module TIND
        include XmlBase

        MILL_ID_FIELD = '901__m'.freeze
        OCLC_ID_FIELD = '901__o'.freeze
        TIND_ID_FIELD = '035__a'.freeze

        def marc_uri_for(record_id)
          ensure_valid_id(record_id)
          id_field = id_field_for(record_id)
          query_string = URI.encode_www_form(
            'p' => "#{id_field}:\"#{record_id}\"",
            'of' => 'xm'
          )
          URIs.append(base_uri, 'search', '?', query_string)
        end

        def _display_uri_for(record_id)
          ensure_valid_id(record_id)
          URIs.append(base_uri, 'record', record_id)
        end

        private

        def base_uri
          AV::Config.tind_base_uri
        end

        def id_field_for(record_id)
          return MILL_ID_FIELD if record_id =~ AV::Constants::MILLENNIUM_RECORD_RE
          return OCLC_ID_FIELD if record_id =~ AV::Constants::OCLC_RECORD_RE

          TIND_ID_FIELD
        end
      end
    end
  end
end
