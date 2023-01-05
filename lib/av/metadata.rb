require 'av/constants'
require 'av/metadata/fields'
require 'av/metadata/source'
require 'av/restrictions'

module AV
  class Metadata
    include AV::Constants

    attr_reader :record_id, :source

    # TODO: can we stop passing in record ID / stop lazy-loading MARC?
    def initialize(record_id:, source:, marc_record: nil)
      @record_id = record_id
      @source = source
      @marc_record = marc_record
    end

    def bib_number
      return @bib_number if instance_variable_defined?(:@bib_number)

      @bib_number = source.find_bib_number(self)
    end

    def tind_id
      id_001 if source == Source::TIND
    end

    def alma_id
      id_001 if source == Source::ALMA
    end

    def marc_record
      @marc_record ||= source.record_for(record_id)
    end

    def values_by_field
      @values_by_field ||= Fields.default_values_from(marc_record).tap { |values| ensure_catalog_link(values) }
    end

    def each_value(&)
      values_by_field.each_value(&)
    end

    def title
      @title ||= (title_value = values_by_field[Fields::TITLE]) ? title_value.entries.first : UNKNOWN_TITLE
    end

    def description
      @description ||= (desc_value = values_by_field[Fields::DESCRIPTION]) ? desc_value.as_string : ''
    end

    def calnet_or_ip?
      restrictions.calnet_or_ip?
    end

    def calnet_only?
      restrictions.calnet_only?
    end

    def display_uri
      @display_uri ||= source.display_uri_for(self)
    end

    class << self
      def for_record(record_id:)
        source = Source.for_record_id(record_id)
        raise AV::RecordNotFound, "Unable to determine metadata source for record ID: #{record_id.inspect}" unless source

        Metadata.new(record_id:, source:)
      end
    end

    private

    def restrictions
      @restrictions ||= Restrictions.new(marc_record)
    end

    def id_001
      return @id_001 if instance_variable_defined?(:@id_001)
      return (@id_001 = nil) unless (cf_001 = marc_record['001'])

      @id_001 = RecordId.ensure_record_id(cf_001.value)
    end

    def ensure_catalog_link(values_by_field)
      catalog_value = values_by_field[Fields::CATALOG_LINK]
      return if catalog_value && catalog_value.includes_link?(source.catalog_link_text)

      catalog_link = Link.new(url: display_uri.to_s, body: source.catalog_link_text)

      if catalog_value
        catalog_value.entries << catalog_link
      else
        values_by_field[Fields::CATALOG_LINK] = Value.link_value(Fields::CATALOG_LINK, catalog_link)
      end
    end

  end
end
