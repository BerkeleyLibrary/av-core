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
      @values ||= Fields.values_from(marc_record)
    end

    def title
      @title ||= begin
        title_field = values.find { |v| v.tag == TAG_TITLE_FIELD }
        first_title_value = title_field && title_field.first
        first_title_value || UNKNOWN_TITLE
      end
    end

    def ucb_access?
      @ucb_access ||= marc_record.fields(TAG_LINK_FIELD).any? do |data_field|
        subfields = data_field.subfields
        subfields.any? { |sf| sf.value.include?('UCB access') }
      end
    end

    private

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
