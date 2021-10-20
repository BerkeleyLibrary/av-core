require 'av/util'
require 'av/record_not_found'

module AV
  class Metadata
    module Readers
      module XmlBase
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
            raise not_found(record_id, marc_uri, "GET #{marc_uri} returned: #{xml}") unless record
          end
        end

        def not_found(record_id, marc_uri = nil, details)
          AV::RecordNotFound.new("Can't find #{name} record for ID #{record_id} at MARC URI #{marc_uri || marc_uri_for(record_id)}: #{details}")
        end
      end
    end
  end
end
