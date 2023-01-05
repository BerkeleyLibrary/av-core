require 'berkeley_library/util/uris'
require 'berkeley_library/av/util'
require 'berkeley_library/av/metadata/link'

module BerkeleyLibrary
  module AV
    class Metadata
      class Value
        include AV::Util
        include Comparable

        # ------------------------------------------------------------
        # Constants

        URL_CODE = :u
        BODY_CODES = %i[y z].freeze

        # ------------------------------------------------------------
        # Accessors

        # TODO: find uses of :entries & replace them with standardized string value method here
        attr_reader :tag, :label, :entries, :order

        # ------------------------------------------------------------
        # Initializers

        def initialize(tag:, label:, entries:, order:)
          raise ArgumentError, 'Entries cannot be empty' if entries.empty?

          @tag = tag
          @label = label
          @order = order
          @entries = entries
        end

        # ------------------------------------------------------------
        # Public methods

        def includes_link?(link_body)
          entries.any? do |entry|
            entry.is_a?(Link) && entry.body == link_body
          end
        end

        def as_string
          entries.join(' ').gsub(/[[:space:]]+/, ' ')
        end

        # ------------------------------
        # Object overrides

        def to_s
          StringIO.new.tap do |out|
            out << "#{label} (#{tag}): "
            out << entries.join(' ')
          end.string
        end

        # @param other [Value] the Value to compare
        def <=>(other)
          compare_by_attributes(self, other, :order, :tag, :entries, :label)
        end

        # ------------------------------------------------------------
        # Class methods

        class << self
          include AV::Util
          include BerkeleyLibrary::Util::URIs

          def value_for(field, subfield_groups)
            return if subfield_groups.empty?
            return if (all_entries = entries_from_groups(subfield_groups, field.subfields_separator)).empty?

            Value.new(tag: field.tag, label: field.label, entries: all_entries, order: field.order)
          end

          def link_value(field, link)
            Value.new(tag: field.tag, label: field.label, order: field.order, entries: [link])
          end

          private

          def entries_from_groups(subfield_groups, separator)
            subfield_groups.each_with_object([]) do |sg, entries|
              entries.concat(entries_from_group(sg, separator))
            end
          end

          def entries_from_group(subfield_group, separator)
            [].tap do |entries|
              link = extract_link(subfield_group)
              entries << link if link

              subfield_values = subfield_group.values.map { |sf| tidy_value(sf.value) }
              entries << subfield_values.join(separator) unless subfield_values.empty?
            end
          end

          def extract_link(subfield_group)
            return unless (url_sf = subfield_group.delete(URL_CODE))

            url = url_sf.value
            body = link_body_from(subfield_group) || url
            AV::Metadata::Link.new(url:, body:)
          end

          def link_body_from(subfield_group)
            body_sf = BODY_CODES.lazy.filter_map { |code| subfield_group.delete(code) }.first
            return unless body_sf

            body_value = tidy_value(body_sf.value)
            body_value unless body_value.empty?
          end

        end

      end
    end
  end
end
