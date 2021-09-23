require 'av/config'
require 'av/util'
require 'av/record_not_found'

module AV
  class Metadata
    module Readers
      module TIND
        include AV::Util

        MILL_ID_FIELD = '901__m'.freeze
        OCLC_ID_FIELD = '901__o'.freeze
        TIND_ID_FIELD = '035__a'.freeze

        # @return [MARC::Record] the MARC record
        def record_for(record_id)
          first_record_for(record_id)
        rescue AV::RecordNotFound
          raise
        rescue StandardError => e
          raise record_not_found(record_id, e.message)
        end

        def marc_uri_for(record_id)
          ensure_valid_id(record_id)
          id_field = id_field_for(record_id)
          URI.join(base_uri, '/search').tap do |search_uri|
            search_uri.query = URI.encode_www_form(
              'p' => "#{id_field}:\"#{record_id}\"",
              'of' => 'xm'
            )
          end
        end

        def _display_uri_for(record_id)
          ensure_valid_id(record_id)
          URI.join(base_uri, "/record/#{record_id}")
        end

        private

        # @return [MARC::Record] the MARC record
        def first_record_for(record_id)
          marc_uri = marc_uri_for(record_id)
          xml = do_get(marc_uri)
          records = AV::Marc.all_from_xml(xml)
          record = records && records.first
          # noinspection RubyYardReturnMatch
          return record if record

          raise record_not_found(record_id, "GET #{marc_uri} returned: #{xml}")
        end

        def record_not_found(record_id, details)
          AV::RecordNotFound.new("Can't find TIND record for ID #{record_id.inspect} at MARC URI #{marc_uri_for(record_id)}: #{details}")
        end

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
