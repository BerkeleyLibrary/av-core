require 'av/metadata/field'

module AV
  class Metadata
    class Fields
      TITLE = Field.new(label: 'Title', tag: '245', order: 1, subfield_order: [:a])
      DESCRIPTION = Field.new(label: 'Description', tag: '520', order: 2, subfield_order: [:a])
      CREATOR_PERSONAL = Field.new(label: 'Creator', tag: '700', order: 2)
      CREATOR_CORPORATE = Field.new(label: 'Creator', tag: '710', order: 2)
      LINKS_HTTP = Field.new(label: 'Linked Resources', tag: '856', ind_1: '4', ind_2: '1', order: 11)
      TRACKS = Field.new(label: 'Tracks', tag: '998', ind_1: '0', ind_2: '0', order: 99, subfield_order: %i[g t a])
      DEFAULT_FIELDS = [TITLE, DESCRIPTION, CREATOR_PERSONAL, CREATOR_CORPORATE, LINKS_HTTP, TRACKS].freeze

      JSON_REQUIRED_FIELDS = %w[visible params labels order].freeze
      TAG_RE = /([0-9]{3})([a-z0-9_%])([a-z0-9_%])([a-z0-9_%]?)/.freeze

      class << self

        def values_from(marc_record)
          all.map { |f| f.value_from(marc_record) }.compact
        end

        def all
          @all ||= begin
            json_config_path = File.join(__dir__, 'tind_html_metadata_da.json')
            json_config = File.read(json_config_path)
            json = JSON.parse(json_config)

            fields = DEFAULT_FIELDS + json['config'].map { |jf| field_from(jf) }.compact
            unique_fields(fields)
          end
        end

        private

        def unique_fields(fields)
          [].tap do |uniques|
            fields.sort.each do |f|
              already_present = uniques.any? { |u| u.same_field?(f) }
              uniques << f unless already_present
            end
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def field_from(json_field)
          return unless JSON_REQUIRED_FIELDS.all? { |f| json_field[f] }

          # Suppress extra title field in favor of Field::TITLE
          return if json_field['machine_name'] == 'local_245_880_linking'

          label_en = json_field['labels']['en']
          return unless label_en

          params = json_field['params']

          marc_tag = marc_tag_from(params)
          return unless marc_tag

          _, tag, ind_1, ind_2, subfield = TAG_RE.match(marc_tag).to_a

          Field.new(
            order: json_field['order'].to_i,
            label: label_en,
            tag: tag,
            ind_1: meaningful_char_or_nil(ind_1),
            ind_2: meaningful_char_or_nil(ind_2),
            subfields_separator: (params['subfields_separator'] || ' '),
            subfield_order: subfield_order_from(params, subfield)
          )
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def subfield_order_from(params, subfield)
          subfield_order = params['subfield_order'].to_s.split(',').map(&:to_sym)
          return subfield_order unless subfield_order.empty?

          subfield = meaningful_char_or_nil(subfield)
          [subfield.to_sym] if subfield
        end

        def marc_tag_from(params)
          %w[tag fields tag_1 tag_2].each do |attr|
            tag = params[attr] && params[attr].strip
            return tag if tag =~ TAG_RE
          end

          return unless (input_tag = params['input_tag'])

          tag = "#{input_tag}#{params['input_subfield']}"
          tag if tag =~ TAG_RE
        end

        def meaningful_char_or_nil(c)
          c unless [nil, '', '%', '_'].include?(c)
        end
      end

      private_class_method(:new)
    end
  end
end
