require 'berkeley_library/util/uris'

require 'berkeley_library/av/config'
require 'berkeley_library/av/record_id'
require 'berkeley_library/av/metadata/readers/base'

module BerkeleyLibrary
  module AV
    class Metadata
      module Readers
        module TIND
          include Base

          TIND_ID_FIELD = '035__a'.freeze

          ID_FIELDS = {
            AV::RecordId::Type::MILLENNIUM => '901__m'.freeze,
            AV::RecordId::Type::OCLC => '901__o'.freeze
          }.freeze

          def marc_uri_for(record_id)
            id_field = id_field_for(record_id)
            query_string = URI.encode_www_form(
              'p' => "#{id_field}:\"#{record_id}\"",
              'of' => 'xm'
            )
            URIs.append(base_uri, 'search', '?', query_string)
          end

          protected

          def _display_uri_for(record_id)
            URIs.append(base_uri, 'record', record_id)
          end

          private

          def base_uri
            AV::Config.tind_base_uri
          end

          def id_field_for(record_id)
            id_type = AV::RecordId::Type.for_id(record_id)
            raise ArgumentError, "Can't look up Alma record #{record_id} in TIND" if id_type == AV::RecordId::Type::ALMA

            ID_FIELDS[id_type] || TIND_ID_FIELD
          end
        end
      end
    end
  end
end
