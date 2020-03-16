require 'av/constants'
require 'av/types/duration'
require 'av/types/file_type'
require 'av/marc/subfield_groups'
require 'marc'

module AV
  class Track
    include Comparable
    include AV::Constants
    include AV::Util

    attr_reader :sort_order, :title, :path, :duration, :file_type

    def initialize(sort_order:, title: nil, path:, duration: nil)
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
