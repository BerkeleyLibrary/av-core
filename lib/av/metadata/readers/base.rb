require 'av/util'
require 'av/record_not_found'

module AV
  class Metadata
    module Readers
      module Base
        include AV::Util

        # @return [MARC::Record] the MARC record
        def record_for(record_id)
          first_record_for(record_id)
        rescue AV::RecordNotFound
          raise
        rescue StandardError => e
          raise not_found(record_id, e.message)
        end

        private

        # @return [MARC::Record] the MARC record
        def first_record_for(record_id)
          marc_uri = marc_uri_for(record_id)
          record_from(marc_uri, record_id)
        end

        def record_from(marc_uri, record_id)
          xml = do_get(marc_uri)
          AV::Marc.from_xml(xml).tap do |record|
            raise not_found(record_id, "GET #{marc_uri} returned: #{xml}", marc_uri:) unless record
          end
        end

        def not_found(record_id, details, marc_uri: nil)
          msg = "Can't find #{name} record for ID #{record_id}: #{details}."

          marc_uri_msg = marc_uri_message(record_id, marc_uri)
          msg = [msg, marc_uri_msg].join(' ') if marc_uri_msg

          AV::RecordNotFound.new(msg)
        end

        def marc_uri_message(record_id, marc_uri)
          " MARC URI: #{marc_uri | marc_uri_for(record_id)}"
        rescue StandardError
          # nil
        end
      end
    end
  end
end
