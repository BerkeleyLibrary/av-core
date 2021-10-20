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
      compare_by_attributes(self, other, :sort_order, :title, :duration, :path)
    end

    def to_s
      ''.tap do |s|
        s << "#{sort_order}: " if sort_order
        s << path
        s << " #{title.inspect}" if title
        s << " (#{duration})" if duration
      end
    end

    def inspect
      "\#<#{self.class.name} #{self}>"
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
      include AV::Marc::Util

      LABELS = {
        SUBFIELD_CODE_DURATION => 'duration',
        SUBFIELD_CODE_TITLE => 'title',
        SUBFIELD_CODE_PATH => 'path'
      }.freeze

      # Note that if multiple tracks are encoded in the same 998 field, the
      # subfields **must** be in the order :a, :t, :g (duration, title, path),
      # as documented in {https://docs.google.com/document/d/1gRWsaSoerSvadNlYR-zbYOjgj0geLxV41bBC0rm5nHE/edit
      # "How to add media to the AV System"}.
      #
      # @param marc_record [MARC::Record] the MARC record
      # @param collection [String] the collection
      def tracks_from(marc_record, collection:)
        track_fields = marc_record.fields(TAG_TRACK_FIELD)
        track_fields.each_with_object([]) do |df, all_tracks|
          value_groups = group_values(df.subfields)
          value_groups.each do |group|
            all_tracks << from_value_group(group, collection: collection, sort_order: all_tracks.size)
          end
        end
      end

      private

      def group_values(subfields)
        filtered = subfields.select { |sf| SUBFIELD_CODES_TRACKS.include?(sf.code.to_sym) }
        group_subfields(filtered).map { |sfg| to_value_group(sfg) }
      end

      def group_subfields(subfields)
        single_track = subfields.lazy.select { |sf| sf.code.to_sym == SUBFIELD_CODE_PATH }.one?
        return [group_together(subfields)] if single_track

        group_on_paths(subfields)
      end

      def group_together(subfields)
        subfields.each_with_object({}) { |sf, grp| grp[sf.code.to_sym] = sf }
      end

      def group_on_paths(subfields)
        current_group = {}
        subfields.each_with_object([]) do |subfield, groups|
          code_sym = subfield.code.to_sym

          current_group[code_sym] = subfield
          if code_sym == SUBFIELD_CODE_PATH
            groups << current_group
            current_group = {}
          end
        end
      end

      def to_value_group(subfield_group)
        subfield_group.transform_values { |sf| tidy_value(sf.value) }
      end

      def from_value_group(group, collection:, sort_order:)
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
