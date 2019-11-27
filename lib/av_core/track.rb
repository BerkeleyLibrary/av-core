module AVCore
  class Track
    include Comparable

    attr_reader :sort_order, :title, :path, :duration, :file_type

    def initialize(sort_order:, title: nil, path:, duration: nil)
      @sort_order = sort_order
      @title = title
      @path = path
      @duration = duration
      @file_type = FileType.for_path(path)
    end

    def <=>(other)
      return 0 if equal?(other)

      %i[sort_order title duration path].each do |attr|
        order = send(attr) <=> other.send(attr)
        return order if order && order != 0
      end

      0
    end

    class << self
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
        tracks_field = Metadata::Fields::Readers::TRACKS.create_field(marc_record)
        tracks_field ? tracks_field.tracks : []
      end
    end
  end
end
