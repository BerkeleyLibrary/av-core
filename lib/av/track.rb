require 'av/constants'
require 'av/types/duration'
require 'av/types/file_type'
require 'av/marc/util'
require 'marc'

module AV
  class Track
    include Comparable
    include AV::Constants
    include AV::Util

    attr_reader :sort_order, :title, :path, :duration, :file_type

    def initialize(sort_order:, path:, title: nil, duration: nil)
      @sort_order = sort_order
      @title = title
      @path = path
      @duration = duration_or_nil(duration)
      @file_type = AV::Types::FileType.for_path(path)
    end

    def <=>(other)
      return 0 if equal?(other)
      return unless other

      %i[sort_order title duration path].each do |attr|
        return nil unless other.respond_to?(attr)

        o = compare_values(send(attr), other.send(attr))
        return o if o && o != 0
      end

      0
    end

    def to_s
      ''.tap do |s|
        s << "#{sort_order}. " if sort_order
        s << "#{title}: " if title
        s << path
        s << " (#{duration})" if duration
      end
    end

    def inspect
      "\#<#{self.class.name}:#{format('%016x', 2 * object_id)} #{self}>"
    end

    # @return [Array<MARC::Subfield>]
    def to_marc_subfields
      [].tap do |subfields|
        subfields << MARC::Subfield.new(SUBFIELD_CODE_DURATION, duration.to_s) if duration
        subfields << MARC::Subfield.new(SUBFIELD_CODE_TITLE, title) if title
        subfields << MARC::Subfield.new(SUBFIELD_CODE_PATH, path)
      end
    end

    private

    def duration_or_nil(duration)
      return duration if duration.is_a?(AV::Types::Duration)

      AV::Types::Duration.from_string(duration)
    end

    class << self
      include AV::Constants
      include AV::Util

      TRACKS_FIELD = AV::Metadata::Fields::TRACKS
      LABELS = {
        SUBFIELD_CODE_DURATION => 'duration',
        SUBFIELD_CODE_TITLE => 'title',
        SUBFIELD_CODE_PATH => 'path'
      }.freeze

      def tracks_from(marc_record, collection:)
        [].tap do |tracks|
          marc_record.each_by_tag(TRACKS_FIELD.tag) do |df|
            group_subfield_values(df).each do |group|
              tracks << from_group(group, collection: collection, sort_order: tracks.size)
            end
          end
        end
      end

      private

      def group_subfield_values(df)
        values_by_code = values_from(df.subfields)
        AV::Marc::Util.group_values_by_code(values_by_code, order: TRACKS_FIELD.subfield_order)
      end

      def values_from(subfields)
        values_by_code = AV::Marc::Util.values_by_code(subfields)
        return {} unless (paths = values_by_code[SUBFIELD_CODE_PATH])

        values_by_code.reject do |code, values|
          (values.size != paths.size).tap do |mismatch|
            warn_inconsistency(code, values, paths.size) if mismatch
          end
        end
      end

      def warn_inconsistency(code, values, expected_size)
        msg = "Dropping inconsistent track info for subfield #{code} (#{LABELS[code]}): " \
                "expected #{expected_size} values, got #{values.size} (#{values})"
        log.warn(msg)
      end

      def from_group(group, collection:, sort_order:)
        title = tidy_value(group[SUBFIELD_CODE_TITLE])
        path = tidy_value(group[SUBFIELD_CODE_PATH])
        duration = tidy_value(group[SUBFIELD_CODE_DURATION])
        Track.new(
          sort_order: sort_order,
          title: title,
          path: "#{collection}/#{path}",
          duration: duration
        )
      end

    end
  end
end
