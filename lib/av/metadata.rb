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

    def initialize(record_id:, source:, marc_record: nil)
      @record_id = record_id
      @source = source
      @marc_record = marc_record
    end

    def bib_number
      @bib_number ||= find_bib_number
    end

    def tind_id
      (tind_id_field = marc_record['001']) && tind_id_field.value
    end

    def marc_record
      @marc_record ||= source.record_for(record_id)
    end

    def values
      @values ||= Fields.values_from(marc_record).tap { |values| ensure_catalog_link(values) }
    end

    def each_value
      Enumerator.new { |y| values.each { |v| y << v } }
    end

    def title
      @title ||= begin
        title_field = values.find { |v| v.tag == TAG_TITLE_FIELD }
        first_title_value = title_field && title_field.lines.first
        first_title_value || UNKNOWN_TITLE
      end
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
        raise AV::RecordNotFound, "Unable to determine metadata source for record ID: #{record_id}" unless source

        Metadata.new(record_id: record_id, source: source)
      end
    end

    private

    def restrictions_from_links
      link_field_values = marc_record.fields(TAG_LINK_FIELD).flat_map { |data_field| data_field.subfields.map(&:value) }
      RESTRICTIONS.find { |r| link_field_values.any? { |v| v.include?(r) } }
    end

    def ensure_catalog_link(values)
      return values if values.any? { |v| Fields::CATALOG_LINK.value?(v) && v.has_link?(body: source.catalog_link_text) }
      return values unless bib_number

      values << LinkValue.new(
        tag: Fields::CATALOG_LINK.tag,
        label: Fields::CATALOG_LINK.label,
        order: Fields::CATALOG_LINK.order,
        links: [Link.new(body: source.catalog_link_text, url: display_uri.to_s)]
      )
      values.sort!
    end

    def find_bib_number
      return record_id if source == Source::MILLENNIUM

      marc_record.each_by_tag(TAG_TIND_CATALOG_ID) do |data_field|
        subfield_m = data_field.find { |sf| sf.code = SUBFIELD_CODE_MILLENNIUM_ID }
        return subfield_m.value if subfield_m
      end
      nil
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
