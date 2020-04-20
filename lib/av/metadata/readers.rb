module AV
  class Metadata
    module Readers
      MILLENNIUM_RECORD_RE = /^b[0-9]+$/.freeze
      OCLC_RECORD_RE = /^o[0-9]+$/.freeze

      module Millennium
        class << self
          include AV::Util

          def record_for(record_id)
            marc_uri = marc_uri_for(record_id)
            begin
              html = do_get(marc_uri)
              AV::Marc::Millennium.marc_from_html(html)
            rescue StandardError => e
              raise AV::RecordNotFound, "Can't find Millennium record for bib number #{record_id.inspect} at MARC URI #{marc_uri}: #{e.message}"
            end
          end

          def marc_uri_for(record_id)
            URI.join(base_uri, "search~S1?/.#{record_id}/.#{record_id}/1%2C1%2C1%2CB/marc~#{record_id}")
          end

          def display_uri_for(bib_number)
            URI.join(base_uri, "record=#{bib_number}")
          end

          private

          def base_uri
            AV::Config.millennium_base_uri
          end
        end
      end

      module TIND
        class << self
          include AV::Util

          MILL_ID_FIELD = '901__m'.freeze
          OCLC_ID_FIELD = '901__o'.freeze
          TIND_ID_FIELD = '035__a'.freeze

          def record_for(record_id)
            marc_uri = marc_uri_for(record_id)
            begin
              records = records_for(marc_uri)
              record = records && records.first
              return record if record
            rescue StandardError => e
              raise record_not_found(record_id, marc_uri, e.message)
            end

            raise record_not_found(record_id, marc_uri, 'no records returned')
          end

          def marc_uri_for(record_id)
            id_field = id_field_for(record_id)
            URI.join(base_uri, '/search').tap do |search_uri|
              search_uri.query = URI.encode_www_form(
                'p' => "#{id_field}:\"#{record_id}\"",
                'of' => 'xm'
              )
            end
          end

          def display_uri_for(tind_id)
            URI.join(base_uri, "/record/#{tind_id}")
          end

          private

          def records_for(marc_uri)
            xml = do_get(marc_uri)
            AV::Marc.all_from_xml(xml)
          end

          def record_not_found(record_id, marc_uri, details)
            AV::RecordNotFound.new("Can't find TIND record for ID #{record_id.inspect} at MARC URI #{marc_uri}: #{details}")
          end

          def base_uri
            AV::Config.tind_base_uri
          end

          def id_field_for(record_id)
            return MILL_ID_FIELD if record_id =~ Readers::MILLENNIUM_RECORD_RE
            return OCLC_ID_FIELD if record_id =~ Readers::OCLC_RECORD_RE

            TIND_ID_FIELD
          end
        end
      end
    end
  end
end
