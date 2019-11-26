require 'av_core/util'

module AVCore
  module Metadata
    module Fields
      class TrackField < Field

        attr_reader :tracks

        def initialize(tag:, label:, tracks:)
          super(tag: tag, label: label)
          @tracks = tracks
        end

        def to_s
          "#{label} (#{tag}): #{tracks.map(&:to_s).join('; ')}"
        end

        class << self
          include AVCore::Util::Constants

          def from_subfield_values(all_subfield_values, tag:, label:)
            tracks = []
            all_subfield_values.each do |subfield_values|
              subfield_values.each do |subfield_values_by_code|
                next unless subfield_values_by_code.key?(SUBFIELD_CODE_PATH)

                tracks << to_track_info(subfield_values_by_code)
              end
            end
            TrackField.new(tag: tag, label: label, tracks: tracks)
          end

          private

          def to_track_info(subfield_values_by_code)
            TrackInfo.new(
              path: subfield_values_by_code[SUBFIELD_CODE_PATH],
              title: subfield_values_by_code[SUBFIELD_CODE_TITLE],
              duration: AVCore::Util::Duration.from_string(subfield_values_by_code[SUBFIELD_CODE_DURATION])
            )
          end
        end

      end
    end
  end
end
