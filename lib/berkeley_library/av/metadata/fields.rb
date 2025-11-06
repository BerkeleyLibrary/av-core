require 'berkeley_library/av/metadata/field'

module BerkeleyLibrary
  module AV
    class Metadata
      module Fields
        include AV::Constants

        TITLE = Field.new(order: 1, label: 'Title', spec: "#{TAG_TITLE_FIELD}$a")

        DESCRIPTION = Field.new(order: 2, label: 'Description', spec: '520$a')
        CREATOR_PERSONAL = Field.new(order: 2, label: 'Creator', spec: '700')
        CREATOR_CORPORATE = Field.new(order: 2, label: 'Creator', spec: '710')
        TRACKS = Field.new(order: 99, label: 'Tracks', spec: TAG_TRACK_FIELD, subfield_order: %w[g t a])
        CATALOG_LINK = Field.new(order: 998, label: 'Linked Resources', spec: "#{TAG_LINK_FIELD}{^1=\\4}{^2=\\1}")
        # rubocop:disable Layout/LineLength
        TRANSCRIPTS = Field.new(order: 999, label: 'Transcripts', spec: "#{TAG_TRANSCRIPT_FIELD}{$y~\\Transcript}{^1=\\4}{^2=\\2}", subfield_order: %w[u y])
        # rubocop:enable Layout/LineLength

        STANDARD_FIELDS = [
          TITLE,
          DESCRIPTION,
          CREATOR_PERSONAL,
          CREATOR_CORPORATE,
          TRACKS,
          TRANSCRIPTS,
          CATALOG_LINK
        ].freeze

        TIND_CONFIG = File.join(__dir__, 'tind_html_metadata_da.json')

        REQ_ATTRS = %w[visible params labels order].freeze
        TAG_ATTRS = %w[tag fields tag_1 tag_2].freeze
        TAG_RE = /(?<tag>[0-9]{3})(?<ind1>[a-z0-9_%])(?<ind2>[a-z0-9_%])(?<subfield>[a-z0-9])?/

        class << self

          def default_fields
            @default_fields ||= begin
              default_fields = STANDARD_FIELDS + from_tind_config(TIND_CONFIG)
              unique_by_metadata(default_fields)
            end
          end

          def from_tind_config(json_config)
            json_config_hash = ensure_hash(json_config)
            json_config_hash['config'].filter_map { |jf| to_field(jf) }
          end

          def default_values_from(marc_record)
            default_fields.each_with_object({}) do |f, vv|
              field_value = f.value_from(marc_record)
              vv[f] = field_value if field_value
            end
          end

          private

          # @return [Hash] the config hash
          def ensure_hash(json_config)
            json_config = File.read(json_config) if File.file?(json_config)
            json_config.is_a?(Hash) ? json_config : JSON.parse(json_config)
          end

          # rubocop:disable Metrics/MethodLength
          def to_field(json_field)
            return unless can_display?(json_field)

            params = json_field['params']
            tag, marc_spec = tag_and_spec_from(params)
            return unless tag

            Field.new(
              order: json_field['order'].to_i,
              label: json_field['labels']['en'],
              tag:,
              spec: marc_spec,
              subfields_separator: params['subfields_separator'] || ' ',
              subfield_order: params['subfield_order'].to_s.split(',')
            )
          end
          # rubocop:enable Metrics/MethodLength

          def unique_by_metadata(fields)
            fields.sort.each_with_object([]) do |f, uniques|
              already_present = uniques.any? { |u| u.same_metadata?(f) }
              uniques << f unless already_present
            end
          end

          def can_display?(json_field)
            REQ_ATTRS.all? { |f| json_field[f] } &&
              json_field['labels'].key?('en') &&
              json_field['machine_name'] != 'local_245_880_linking' # extra title
          end

          def tag_and_spec_from(params)
            tag_and_spec = TAG_ATTRS.lazy.filter_map { |attr| parse_tag_and_spec(params[attr]) }.first
            return tag_and_spec if tag_and_spec

            return unless (input_tag = params['input_tag'])

            input_subfield = params['input_subfield']
            parse_tag_and_spec("#{input_tag}#{input_subfield}")
          end

          def parse_tag_and_spec(val)
            return unless (md = TAG_RE.match(val))

            tag = md[:tag]
            [tag, to_marc_spec(tag, md[:ind1], md[:ind2], md[:subfield])]
          end

          def to_marc_spec(tag, ind1_val, ind2_val, subfield)
            [
              tag,
              to_subfield_spec(subfield),
              to_ind_spec(1, ind1_val),
              to_ind_spec(2, ind2_val)
            ].join
          end

          def to_subfield_spec(sf)
            "$#{sf}" if sf
          end

          def to_ind_spec(i, ind_val)
            "{^#{i}=\\#{ind_val}}" unless [nil, '', '%', '_'].include?(ind_val)
          end
        end
      end
    end
  end
end
