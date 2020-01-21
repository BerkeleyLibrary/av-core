require 'av/constants'
require 'av/metadata/source'
require 'av/metadata/fields'
require 'av/metadata/source'

module AV
  class Metadata
    include AV::Constants

    UNKNOWN_TITLE = 'Unknown title'.freeze

    attr_reader :record_id, :source

    def initialize(record_id:, source:, marc_record: nil)
      @record_id = record_id
      @source = source
      @marc_record = marc_record
    end

    def bib_number
      @bib_number ||= find_bib_number
    end

    def marc_record
      @marc_record ||= source.record_for(record_id)
    end

    def values
      @values ||= begin
        values = Fields.values_from(marc_record)
        ensure_catalog_link(values)
      end
    end

    def title
      @title ||= begin
        title_field = values.find { |v| v.tag == TAG_TITLE_FIELD }
        first_title_value = title_field && title_field.lines.first
        first_title_value || UNKNOWN_TITLE
      end
    end

    def ucb_access?
      @ucb_access ||= marc_record.fields(TAG_LINK_FIELD).any? do |data_field|
        subfields = data_field.subfields
        subfields.any? { |sf| sf.value.include?('UCB access') }
      end
    end

    def display_uri
      @display_uri ||= Source::MILLENNIUM.display_uri_for(bib_number)
    end

    private

    def ensure_catalog_link(values)
      return values if values.any? { |v| Fields::CATALOG_LINK.value?(v) }
      return values unless bib_number

      values << LinkValue.new(
        tag: Fields::CATALOG_LINK.tag,
        label: Fields::CATALOG_LINK.label,
        order: Fields::CATALOG_LINK.order,
        links: [Link.new(body: 'View library catalog record.', url: display_uri.to_s)]
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

    class << self
      def for_record(record_id:)
        source = Source.for_record_id(record_id)
        raise AV::RecordNotFound, "Unable to determine metadata source for record ID: #{record_id}" unless source

        Metadata.new(record_id: record_id, source: source)
      end
    end
  end
end
