# TODO: put this somewhere more sensible
class String
  def blank?
    empty? || ''.equal?(strip)
  end
end

module AVCore
  module Metadata
    module Fields
      # rubocop:disable Metrics/ClassLength
      class Reader
        include Comparable

        TAG_RE = /([0-9]{3})([a-z0-9_%])([a-z0-9_%])([a-z0-9_%]?)/.freeze
        SUBJECT_TAG_RE = /6[0-9]{2}/.freeze

        ATTRS = %i[order tag ind_1 ind_2 subfield label subfields_separator subfield_order].freeze
        FIELD_LOOKUP_ATTRS = (ATTRS - %i[order label]).freeze

        ATTRS.each { |attr| attr_reader attr }

        # rubocop:disable Metrics/AbcSize
        def initialize(order:, marc_tag:, label:, subfields_separator: ' ', subfield_order: nil)
          md = TAG_RE.match(marc_tag)
          raise ArgumentError, "Invalid MARC tag #{marc_tag}" unless md

          @tag = md[1]
          @ind_1 = Reader.indicator(md[2])
          @ind_2 = Reader.indicator(md[3])

          @subfield = md[4] unless md[4].blank? || md[4] == '%'

          @subfield_order = subfield_order && !subfield_order.blank? ? subfield_order.split(',') : nil

          @label = label
          @subfields_separator = subfields_separator
          @order = order
        end

        # rubocop:enable Metrics/AbcSize

        def link?
          tag == '856'
        end

        # @param marc_record [MARC::Record]
        # @return [Metadata::Fields::Field]
        def create_field(marc_record)
          values = values_from(marc_record)
          return if values.empty?

          return link_field_from(values) if link?

          text_field_from(values)
        end

        # @param other [Reader] the Reader to compare
        def <=>(other)
          return unless other
          return 0 if equal?(other)

          (ATTRS - [:subfield_order]).each do |attr|
            order = compare_attrs(attr, other)
            return nil if order.nil?
            return order if order != 0
          end

          s1 = subfield_order&.join
          s2 = other.subfield_order&.join
          compare_values(s1, s2)
        end

        def to_s
          attr_vals = ATTRS.map do |attr|
            "#{attr}: #{send(attr).inspect}"
          end.join(', ')

          "#<#{self.class.name}: #{attr_vals}>"
        end

        # @param other [Reader] the Reader to compare
        # @return [Boolean] true if this represents the same MARC tag/field/subfields as the specified other, false otherwise
        def same_field?(other)
          FIELD_LOOKUP_ATTRS.each do |attr|
            return false unless other.respond_to?(attr)

            v1 = send(attr)
            v2 = other.send(attr)
            return false if v1 != v2
          end
          true
        end

        class << self
          def indicator(ind_char)
            ind_char if ind_char && ind_char != '%' && ind_char != '_'
          end

          # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def from_json(json_field)
            return unless json_field['visible']

            # Suppress extra title field in favor of Field::TITLE
            return if json_field['machine_name'] == 'local_245_880_linking'

            params = json_field['params']
            return unless params

            labels = json_field['labels']
            return unless labels

            label_en = labels['en']
            return unless label_en

            marc_tag = find_marc_tag(json_field)
            return unless marc_tag

            Reader.new(
              order: json_field['order'],
              marc_tag: marc_tag,
              label: label_en,
              subfields_separator: params['subfields_separator'] || ' ',
              subfield_order: params['subfield_order']
            )
          end
          # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def find_marc_tag(json)
            params = json['params']

            if (tag = params['tag'])
              return tag unless tag.blank?
            end

            if (fields = params['fields'])
              return fields unless fields.blank?
            end

            if (tag = params['tag_1'])
              return tag unless tag.blank?
            end

            if (tag = params['tag_2'])
              return tag unless tag.blank?
            end

            if (input_tag = params['input_tag'])
              return "#{input_tag}#{params['input_subfield']}"
            end

            nil
          end
          # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        end

        private

        def compare_attrs(attr, other)
          return nil unless other.respond_to?(attr)

          compare_values(send(attr), other.send(attr))
        end

        def compare_values(v1, v2)
          return 0 if v1 == v2
          return 1 if v1.nil?
          return -1 if v2.nil?

          v1 < v2 ? -1 : 1
        end

        # @param values [Array<Hash{Symbol=>String}>]
        def link_field_from(values)
          links = values.map { |field| Link.new(body: field[:y], url: field[:u]) }
          LinkField.new(tag: tag, label: label, links: links)
        end

        # @param values [Array<Hash{Symbol=>String}>]
        def text_field_from(values)
          lines = values.map { |field| field.values.join(subfields_separator) }
          TextField.new(tag: tag, label: label, lines: lines)
        end

        # Finds the values for this field in a MARC record.
        # @param marc_record [MARC::Record]
        # @return [Array<Hash{Symbol=>String}>]
        def values_from(marc_record)
          values = []
          marc_record.each_by_tag(tag) do |field|
            value = value_from(field)
            values << value unless value.empty?
          end
          values
        end

        # @param data_field MARC::DataField
        # @return [Hash{Symbol=>String}]
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def value_from(data_field)
          raise ArgumentError, "Field has wrong tag: expected #{tag}, was #{data_field.tag}" unless tag == data_field.tag
          return {} if ind_1 && ind_1 != data_field.indicator1
          return {} if ind_2 && ind_2 != data_field.indicator2

          if subfield
            subfield_value = data_field[subfield]
            return subfield_value ? { subfield.to_sym => subfield_value } : {}
          end

          extract_subfield_values(data_field)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def extract_subfield_values(data_field)
          return ordered_subfields(data_field) if subfield_order

          all_subfields(data_field)
        end

        def all_subfields(data_field)
          subfield_values = {}
          data_field.subfields.each do |subfield|
            subfield_value = subfield.value
            # TODO: solve https://github.com/fguillen/simplecov-rcov/issues/20 and use proper em dash
            subfield_value = '-- ' + subfield_value if data_field.tag =~ SUBJECT_TAG_RE && 'xyz'.include?(subfield.code)
            subfield_values[subfield.code.to_sym] = subfield_value if subfield_value
          end
          subfield_values
        end

        def ordered_subfields(data_field)
          subfield_values = {}
          subfield_order.each do |code|
            subfield_value = data_field[code]
            subfield_values[code.to_sym] = subfield_value if subfield_value
          end
          subfield_values
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
