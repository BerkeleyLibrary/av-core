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
      new(:TIND) { singleton_class.include(Readers::TIND) }
      new(:MILLENNIUM) { singleton_class.include(Readers::Millennium) }

      LINK_TEXT_MILLENNIUM = 'View library catalog record.'.freeze
      LINK_TEXT_TIND = 'View record in Digital Collections.'.freeze

      class << self
        def for_record_id(record_id)
          record_id =~ AV::Constants::MILLENNIUM_RECORD_RE ? Source::MILLENNIUM : Source::TIND
        end
      end

      def catalog_link_text
        return LINK_TEXT_MILLENNIUM if self == MILLENNIUM
        return LINK_TEXT_TIND if self == TIND

        raise ArgumentError, "Unsupported metadata source: #{self}"
      end

      def display_uri_for(metadata)
        record_id = canonical_record_id_for(metadata)
        _display_uri_for(record_id)
      end

      def canonical_record_id_for(metadata)
        return metadata.bib_number if self == MILLENNIUM && metadata.respond_to?(:bib_number)
        return metadata.tind_id if self == TIND && metadata.respond_to?(:tind_id)

        raise ArgumentError, "#{self}: unable to determine record ID from metadata #{metadata.inspect}"
      end

      private

      def ensure_valid_id(record_id)
        return record_id if Source.for_record_id(record_id) == self

        raise ArgumentError, "Not a valid record ID for source #{value.inspect}: #{record_id}"
      end

    end
  end
end
