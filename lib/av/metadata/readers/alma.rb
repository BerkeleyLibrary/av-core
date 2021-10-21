require 'berkeley_library/util/uris'

require 'av/config'
require 'av/record_id'
require 'av/metadata/readers/base'

module AV
  class Metadata
    module Readers
      module Alma
        include Base

        def marc_uri_for(record_id)
          query_string = URI.encode_www_form(
            'version' => '1.2',
            'operation' => 'searchRetrieve',
            'query' => sru_query_value_for(record_id)
          )

          URIs.append(AV::Config.alma_sru_base_uri, '?', query_string)
        end

        protected

        def _display_uri_for(record_id)
          URIs.append(AV::Config.alma_permalink_base_uri, "alma#{record_id}")
        end

        private

        def sru_query_value_for(record_id)
          id_type = AV::RecordId::Type.for_id(record_id)
          return "alma.mms_id=#{record_id}" if id_type == AV::RecordId::Type::ALMA
          return millennium_query_value(record_id) if id_type == AV::RecordId::Type::MILLENNIUM

          raise ArgumentError, "Invalid record type: #{id_type}"
        end

        def millennium_query_value(bib_number)
          other_system_number = other_system_number_for_bib(bib_number)
          "alma.other_system_number=#{other_system_number}"
        end

        def other_system_number_for_bib(bib_number)
          bib_number = RecordId.ensure_check_digit(bib_number)
          "UCB-#{bib_number}-#{AV::Config.alma_institution_code.downcase}"
        end

      end
    end
  end
end
