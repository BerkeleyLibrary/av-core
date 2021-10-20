require 'av/constants'
require 'av/metadata/fields'
require 'av/metadata/source'

module AV
  class Metadata
    include AV::Constants

    SUBFIELD_PLAYER_URL = {
      AV::Metadata::Source::MILLENNIUM => %w[856 4 0 u].freeze,
      AV::Metadata::Source::TIND => %w[856 4 2 u].freeze
    }.freeze

    SUBFIELD_LINK_TEXT = {
      AV::Metadata::Source::MILLENNIUM => %w[856 4 0 z].freeze,
      AV::Metadata::Source::TIND => %w[856 4 2 y].freeze
    }.freeze

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

    def each_value(&block)
      values_by_field.each_value(&block)
    end

    def title
      @title ||= (title_value = values_by_field[Fields::TITLE]) ? title_value.entries.first : UNKNOWN_TITLE
    end

    def description
      @description ||= (desc_value = values_by_field[Fields::DESCRIPTION]) ? desc_value.as_string : ''
    end

    def ucb_access?
      restrictions != RESTRICTIONS_NONE
    end

    def restrictions
      @restrictions ||= (restrictions_from_links || RESTRICTIONS_NONE)
    end

    def display_uri
      @display_uri ||= source.display_uri_for(self)
    end

    def player_url
      @player_url ||= unique_subfield_value(*SUBFIELD_PLAYER_URL[source])
    end

    def player_link_text
      @player_link_text ||= unique_subfield_value(*SUBFIELD_LINK_TEXT[source])
    end

    class << self
      def for_record(record_id:)
        source = Source.for_record_id(record_id)
        raise AV::RecordNotFound, "Unable to determine metadata source for record ID: #{record_id.inspect}" unless source

        Metadata.new(record_id: record_id, source: source)
      end
    end

    private

    def id_001
      return @id_001 if instance_variable_defined?(:@id_001)
      return (@id_001 = nil) unless (cf_001 = marc_record['001'])

      @id_001 = RecordId.ensure_record_id(cf_001.value)
    end

    def restrictions_from_links
      link_field_values = marc_record.fields(TAG_LINK_FIELD).flat_map { |data_field| data_field.subfields.map(&:value) }
      RESTRICTIONS.find { |r| link_field_values.any? { |v| v.include?(r) } }
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

    def unique_subfield_value(tag, ind1, ind2, subfield_code)
      subfield = unique_subfield(tag, ind1, ind2, subfield_code)
      subfield && subfield.value
    end

    def unique_subfield(tag, ind1, ind2, subfield_code)
      subfields = find_subfields(tag, ind1, ind2, subfield_code)
      subfields.size.tap do |count|
        warn("Record #{bib_number}: Expected one #{tag} #{ind1}#{ind2} #{subfield_code}, got #{count}") unless count == 1
      end
      subfields[0]
    end

    def find_subfields(tag, ind1, ind2, subfield_code)
      find_fields(tag, ind1, ind2).flat_map { |df| df.find_all { |sf| sf.code == subfield_code } }
    end

    def find_fields(tag, ind1, ind2)
      marc_record.fields(tag).select { |f| f.indicator1 == ind1 && f.indicator2 == ind2 }
    end

  end
end
