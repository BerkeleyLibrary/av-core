require 'av/constants'
require 'av/types/duration'
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

      def tracks_from(marc_record, collection:)
        [].tap do |tracks|
          marc_record.each_by_tag(TAG_TRACK_FIELD) do |df|
            subfield_values = AV::Marc::SubfieldGroups.from_data_field(df)
            subfield_values.each do |group|
              next unless group.key?(SUBFIELD_CODE_PATH)

              tracks << from_group(group, collection: collection, sort_order: tracks.size)
            end
          end
        end
      end

      private

      def from_group(group, collection:, sort_order:)
        Track.new(
          sort_order: sort_order,
          title: group[SUBFIELD_CODE_TITLE],
          path: "#{collection}/#{group[SUBFIELD_CODE_PATH]}",
          duration: group[SUBFIELD_CODE_DURATION]
        )
      end
    end
  end
end
