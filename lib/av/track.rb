require 'av/constants'
require 'av/types/file_type'
require 'av/marc/subfield_groups'

module AV
  class Track
    include Comparable

    attr_reader :sort_order, :title, :path, :duration, :file_type

    def initialize(sort_order:, title: nil, path:, duration: nil)
      @sort_order = sort_order
      @title = title
      @path = path
      @duration = ensure_duration(duration)
      @file_type = AV::Types::FileType.for_path(path)
    end

    def <=>(other)
      return 0 if equal?(other)

      %i[sort_order title duration path].each do |attr|
        order = send(attr) <=> other.send(attr)
        return order if order && order != 0
      end

      0
    end

    def to_s
      ''.tap do |s|
        s << "#{sort_order}. " if sort_order
        s << "#{title}: " if title
        s << path
        s << " (#{duration})"
      end
    end

    private

    def ensure_duration(duration)
      return duration if duration.is_a?(AV::Types::Duration)

      AV::Types::Duration.from_string(duration)
    end

    class << self
      include AV::Constants

      def tracks_from(marc_record)
        marc_field_tracks(marc_record).map.with_index do |t, i|
          Track.new(
            sort_order: i,
            title: t.title,
            path: t.path,
            duration: t.duration
          )
        end
      end

      private

      def marc_field_tracks(marc_record)
        [].tap do |tracks|
          marc_record.each_by_tag(TRACK_FIELD_TAG) do |df|
            subfield_values = AV::Marc::SubfieldGroups.from_data_field(df)
            subfield_values.each do |group|
              next unless group.key?(SUBFIELD_CODE_PATH)

              sort_order = tracks.size
              tracks << from_subfield_group(group, sort_order)
            end
          end
        end
      end

      def from_subfield_group(group, sort_order)
        Track.new(
          sort_order: sort_order,
          title: group[SUBFIELD_CODE_TITLE],
          path: group[SUBFIELD_CODE_PATH],
          duration: group[SUBFIELD_CODE_DURATION]
        )
      end
    end
  end
end
