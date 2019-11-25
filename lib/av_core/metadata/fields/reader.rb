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

        ATTRS = %i[order tag ind_1 ind_2 subfields_separator subfield_order label].freeze
        FIELD_LOOKUP_ATTRS = (ATTRS - %i[order label]).freeze

        ATTRS.each { |attr| attr_reader attr }

        # rubocop:disable Metrics/ParameterLists
        def initialize(order:, label:, tag:, ind_1: nil, ind_2: nil, subfields_separator: ' ', subfield_order: nil)
          @order = order
          @label = label
          @tag = tag
          @ind_1 = ind_1
          @ind_2 = ind_2
          @subfields_separator = subfields_separator
          @subfield_order = subfield_order
        end
        # rubocop:enable Metrics/ParameterLists

        def link?
          tag == '856'
        end

        # @param marc_record [MARC::Record]
        # @return [Metadata::Fields::Field]
        def create_field(marc_record)
          all_subfield_values = all_subfield_values_from(marc_record)
          return if all_subfield_values.empty?

          return link_field_from(all_subfield_values) if link?

          text_field_from(all_subfield_values)
        end

        # @param other [Reader] the Reader to compare
        def <=>(other)
          return unless other
          return 0 if equal?(other)

          (ATTRS - [:subfield_order]).each do |attr|
            o = compare_attrs(attr, other)
            return nil if o.nil?
            return o if o != 0
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

          # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
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

            md = TAG_RE.match(marc_tag)
            raise ArgumentError, "Invalid MARC tag #{marc_tag}" unless md

            tag = md[1]

            ind_1 = indicator(md[2])
            ind_2 = indicator(md[3])
            subfield = subfield_or_nil(md[4])

            subfield_order = params['subfield_order']
            subfield_order = subfield_order_or_nil(subfield_order)
            subfield_order ||= [subfield.to_sym] if subfield

            Reader.new(
              order: json_field['order'],
              label: label_en,
              tag: tag,
              ind_1: ind_1,
              ind_2: ind_2,
              subfields_separator: params['subfields_separator'] || ' ',
              subfield_order: subfield_order
            )
          end
          # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

          def subfield_or_nil(sf)
            return nil unless sf
            return nil if sf.strip == ''
            return nil if sf == '%'

            sf
          end

          def subfield_order_or_nil(subfield_order)
            return nil unless subfield_order
            return nil if subfield_order.strip.empty?

            subfield_order.split(',').map(&:to_sym)
          end

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

        # @param all_subfield_values [Array<SubfieldValues>] The subfield values
        def link_field_from(all_subfield_values)
          links = []
          all_subfield_values.each do |subfield_values|
            subfield_values.by_index.each do |value_group|
              next unless value_group.key?(:y) && value_group.key?(:u)

              links << Link.new(body: value_group[:y], url: value_group[:u])
            end
          end
          LinkField.new(tag: tag, label: label, links: links)
        end

        def text_field_from(all_subfield_values)
          lines = []
          all_subfield_values.each do |subfield_values|
            subfield_values.by_index.each do |code_to_value|
              lines << code_to_value.values.join(subfields_separator)
            end
          end
          TextField.new(tag: tag, label: label, lines: lines)
        end

        def all_subfield_values_from(marc_record)
          [].tap do |all_subfield_values|
            marc_record.each_by_tag(tag) do |data_field|
              next unless relevant?(data_field)

              subfield_values = subfield_values_from(data_field)
              all_subfield_values << subfield_values unless subfield_values.empty?
            end
          end
        end

        def relevant?(data_field)
          return false unless tag == data_field.tag
          return false if ind_1 && ind_1 != data_field.indicator1
          return false if ind_2 && ind_2 != data_field.indicator2

          true
        end

        def subfield_values_from(data_field)
          subfield_values = SubfieldValues.from_data_field(data_field)
          return subfield_values.ordered_by(subfield_order) if subfield_order

          subfield_values
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
