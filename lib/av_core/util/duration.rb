module AVCore
  module Util
    class Duration
      include Comparable

      DURATION_RE = /^([0-9]{1,2})?:?([0-9]{2}):?([0-9]{2})$/.freeze

      attr_reader :total_seconds

      def initialize(hours: 0, minutes: 0, seconds: 0)
        @total_seconds = (3600 * hours) + (60 * minutes) + seconds
      end

      def hours
        @hours ||= (total_seconds / 3600).floor
      end

      def minutes
        remainder = total_seconds % 3600
        (remainder / 60).floor
      end

      def seconds
        remainder = total_seconds % 60
        remainder.floor
      end

      def to_s
        format('%02d:%02d:%02d', hours, minutes, seconds)
      end

      def <=>(other)
        return unless other
        return 0 if equal?(other)

        total_seconds <=> other.total_seconds
      end

      class << self
        def from_string(s)
          md = DURATION_RE.match(s)
          return nil unless md

          Duration.new(
            hours: md[1].to_i,
            minutes: md[2].to_i,
            seconds: md[3].to_i
          )
        end
      end
    end
  end
end
