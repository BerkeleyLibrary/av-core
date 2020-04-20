require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/logger'
require 'av/record_not_found'
require 'av/marc'
require 'av/marc/millennium'
require 'av/util'

# TODO: clean up this class
module AV
  class Metadata
    # rubocop:disable Metrics/BlockLength
    class Source < TypesafeEnum::Base
      include AV::Util

      MILLENNIUM_RECORD_RE = /^b[0-9]+$/.freeze
      OCLC_RECORD_RE = /^o[0-9]+$/.freeze

      new :TIND do
        def record_for(record_id)
          begin
            records = records_for_id(record_id)
            record = records && records.first
            return record if record
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find TIND record for record ID #{record_id.inspect}: #{e.message}"
          end

          raise AV::RecordNotFound, "No TIND records found for record id #{record_id}"
        end

        def record_for_bib(bib_number)
          record_id = Source::MILLENNIUM.ensure_valid_id(bib_number)

          record = begin
            marc_reader = records_for_bib(record_id)
            marc_reader && marc_reader.first
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find TIND record for record ID #{record_id.inspect}: #{e.message}"
          end
          return record if record

          raise AV::RecordNotFound, "No TIND records found for Millennium bib number #{bib_number}"
        end

        def id_field_for(record_id)
          return '901__m' if record_id =~ Source::MILLENNIUM_RECORD_RE
          return '901__o' if record_id =~ Source::OCLC_RECORD_RE

          '035__a'
        end

        def records_for_id(record_id)
          id_field = id_field_for(record_id)
          records_for(id_field, record_id)
        end

        def records_for_bib(bib_number)
          record_id = Source::MILLENNIUM.ensure_valid_id(bib_number)
          records_for('901__m', record_id)
        end

        def records_for(field, value)
          search_uri = URI.join(Source::TIND.base_uri, '/search')
          search_uri.query = URI.encode_www_form('p' => "#{field}:\"#{value}\"", 'of' => 'xm')
          xml = do_get(search_uri)
          AV::Marc.all_from_xml(xml)
        rescue StandardError => e
          raise AV::RecordNotFound, "Can't find TIND records for field #{field.inspect}, value #{value.inspect}: #{e.message}"
        end

        def marc_uri_for(tind_id)
          search_uri = URI.join(Source::TIND.base_uri, '/search')
          search_uri.query = URI.encode_www_form('p' => "#{id_field_for(tind_id)}:\"#{tind_id}\"", 'of' => 'xm')
          search_uri
        end

        def display_uri_for(tind_id)
          record_id = ensure_valid_id(tind_id)
          URI.join(base_uri, "/record/#{record_id}")
        end
      end

      new :MILLENNIUM do
        def record_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          begin
            html = do_get(MILLENNIUM.marc_uri_for(record_id))
            AV::Marc::Millennium.marc_from_html(html)
          rescue StandardError => e
            raise AV::RecordNotFound, "Can't find Millennium record for bib number #{record_id}: #{e.message}"
          end
        end

        def marc_uri_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          URI.join(base_uri, "search~S1?/.#{record_id}/.#{record_id}/1%2C1%2C1%2CB/marc~#{record_id}")
        end

        def display_uri_for(bib_number)
          record_id = ensure_valid_id(bib_number)
          URI.join(base_uri, "record=#{record_id}")
        end
      end

      def base_uri
        return AV::Config.millennium_base_uri if self == Source::MILLENNIUM
        return AV::Config.tind_base_uri if self == Source::TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def ensure_valid_id(record_id)
        return record_id if Source.for_record_id(record_id) == self

        raise ArgumentError, "Not a valid record ID for source #{value.inspect}: #{record_id}"
      end

      class << self
        def for_record_id(record_id)
          record_id =~ Source::MILLENNIUM_RECORD_RE ? Source::MILLENNIUM : Source::TIND
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
