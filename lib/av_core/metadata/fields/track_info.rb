module AVCore
  module Metadata
    module Fields
      class TrackInfo
        attr_reader :path, :title, :duration

        def initialize(path:, title:, duration:)
          @path = path
          @title = title
          @duration = duration
        end

        def to_s
          ''.tap do |s|
            s << "#{title}: " if title
            s << path
            s << " (#{duration})"
          end
        end
      end
    end
  end
end
