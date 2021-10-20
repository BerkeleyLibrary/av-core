require 'rest_client'
require 'typesafe_enum'
require 'av/config'
require 'av/constants'
require 'av/record_not_found'
require 'av/marc'
require 'av/marc/millennium'
require 'av/util'
require 'av/metadata/readers'

module AV
  class Metadata
    class Source < TypesafeEnum::Base
      include AV::Constants

      new(:ALMA) { singleton_class.include(Readers::Alma)}
      new(:TIND) { singleton_class.include(Readers::TIND) }
      new(:MILLENNIUM) { singleton_class.include(Readers::Millennium) }

      LINK_TEXT_ALMA = 'View library catalog record.'.freeze # TODO: is this right?
      LINK_TEXT_MILLENNIUM = 'View library catalog record.'.freeze
      LINK_TEXT_TIND = 'View record in Digital Collections.'.freeze

      class << self
        def for_record_id(record_id)
          id_type = RecordId.ensure_record_id(record_id).type
          return ALMA if id_type == RecordId::Type::ALMA
          return MILLENNIUM if id_type == RecordId::Type::MILLENNIUM

          TIND
        end
      end

      def name
        key.to_s
      end

      def catalog_link_text
        return LINK_TEXT_ALMA if self == ALMA
        return LINK_TEXT_MILLENNIUM if self == MILLENNIUM
        return LINK_TEXT_TIND if self == TIND
      end

      def display_uri_for(metadata)
        record_id = canonical_record_id_for(metadata)
        raise ArgumentError, "#{self}: unable to determine record ID from metadata #{metadata.inspect}" unless record_id

        _display_uri_for(record_id)
      end

      def find_bib_number(metadata)
        return alma_bib_number(metadata.marc_record) if self == Source::ALMA
        return tind_bib_number(metadata.marc_record) if self == Source::TIND
        return metadata.record_id if self == Source::MILLENNIUM
      end

      private

      def canonical_record_id_for(metadata)
        accessor = canonical_record_id_accessor
        metadata.send(accessor) if metadata.respond_to?(accessor)
      end

      def canonical_record_id_accessor
        return :alma_id if self == ALMA
        return :bib_number if self == MILLENNIUM
        return :tind_id if self == TIND
      end

      def ensure_valid_id(record_id)
        rec_id = RecordId.ensure_record_id(record_id)
        return rec_id if Source.for_record_id(rec_id) == self

        raise ArgumentError, "Not a valid record ID for source #{value.inspect}: #{record_id}"
      end

      def tind_bib_number(marc_record)
        tag = TAG_TIND_CATALOG_ID
        code = SUBFIELD_CODE_TIND_BIB_NUMBER
        find_subfield_value(marc_record, tag, code)
      end

      def alma_bib_number(marc_record)
        tag = TAG_ALMA_MIGRATION_INFO
        code = SUBFIELD_CODE_ALMA_BIB_NUMBER
        find_subfield_value(marc_record, tag, code)
      end

      # TODO: Use marc/spec
      def find_subfield_value(marc_record, tag, code)
        bib_number = marc_record.fields(tag).filter_map do |df|
          sf = df.find { |sf| sf.code == code }
          sf.value if sf
        end
        bib_number && RecordId.strip_check_digit(bib_number)
      end
    end
  end
end
