require 'av/metadata/source'
require 'av/metadata/fields'

module AV
  class Metadata
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

    private

    def find_bib_number
      return record_id if source == Source::MILLENNIUM

      marc_record.each_by_tag('901') do |data_field|
        subfield_m = data_field.find { |sf| sf.code = 'm' }
        return subfield_m.value if subfield_m
      end
      nil
    end

    class << self
      def for_record(record_id:, source:)
        Metadata.new(record_id: record_id, source: source)
      end
    end
  end
end
