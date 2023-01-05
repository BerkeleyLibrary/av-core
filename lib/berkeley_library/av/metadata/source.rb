require 'rest_client'
require 'typesafe_enum'
require 'berkeley_library/av/config'
require 'berkeley_library/av/constants'
require 'berkeley_library/av/record_not_found'
require 'berkeley_library/av/marc'
require 'berkeley_library/av/util'
require 'berkeley_library/av/metadata/readers'

module BerkeleyLibrary
  module AV
    class Metadata
      class Source < TypesafeEnum::Base
        include AV::Constants

        new(:ALMA) { singleton_class.include(Readers::Alma) }
        new(:TIND) { singleton_class.include(Readers::TIND) }

        LINK_TEXT_ALMA = 'View library catalog record.'.freeze # TODO: is this right?
        LINK_TEXT_TIND = 'View record in Digital Collections.'.freeze

        class << self
          def for_record_id(record_id)
            id_type = RecordId.ensure_record_id(record_id).type
            return ALMA if [RecordId::Type::ALMA, RecordId::Type::MILLENNIUM].include?(id_type)

            TIND
          end
        end

        def name
          key.to_s
        end

        def catalog_link_text
          return LINK_TEXT_ALMA if self == ALMA
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
        end

        private

        def canonical_record_id_for(metadata)
          accessor = canonical_record_id_accessor
          metadata.send(accessor) if metadata.respond_to?(accessor)
        end

        def canonical_record_id_accessor
          return :alma_id if self == ALMA
          return :tind_id if self == TIND
        end

        def tind_bib_number(marc_record)
          tag = TAG_TIND_CATALOG_ID
          code = SUBFIELD_CODE_TIND_BIB_NUMBER
          bib_from_marc(marc_record, tag, code)
        end

        def alma_bib_number(marc_record)
          tag = TAG_ALMA_MIGRATION_INFO
          code = SUBFIELD_CODE_ALMA_BIB_NUMBER
          bib_from_marc(marc_record, tag, code)
        end

        def bib_from_marc(marc_record, tag, code)
          return unless (bib_number = find_subfield_value(marc_record, tag, code))
          return unless RecordId::Type.for_id(bib_number) == RecordId::Type::MILLENNIUM

          RecordId.strip_check_digit(bib_number)
        end

        # TODO: Use marc/spec
        def find_subfield_value(marc_record, tag, code)
          marc_record.fields(tag).filter_map do |df|
            subfield = df.find { |sf| sf.code == code }
            subfield.value if subfield
          end.first
        end
      end
    end
  end
end
