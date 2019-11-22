module AvPlayer
  module Core
    class Track
      include Comparable

      attr_reader :sort_order, :title, :path, :file_type

      def initialize(sort_order:, title: nil, path:)
        @sort_order = sort_order
        @title = title
        @path = path
        @file_type = FileType.for_path(path)
      end

      def <=>(other)
        return 0 if equal?(other)

        order = sort_order <=> other.sort_order
        return order if order && order != 0

        order = title <=> other.title
        return order if order && order != 0

        path <=> other.path
      end
    end
  end
end
