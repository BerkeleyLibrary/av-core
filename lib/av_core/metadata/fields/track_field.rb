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
          def from_subfield_values(all_subfield_values, tag:, label:)
            tracks = []
            all_subfield_values.each do |subfield_values|
              subfield_values.each do |subfield_values_by_code|
                next unless subfield_values_by_code.key?(:g)

                tracks << to_track_info(subfield_values_by_code)
              end
            end
            TrackField.new(tag: tag, label: label, tracks: tracks)
          end

          private

          def to_track_info(subfield_values_by_code)
            TrackInfo.new(
              path: subfield_values_by_code[:g],
              title: subfield_values_by_code[:t],
              duration: Duration.from_string(subfield_values_by_code[:a])
            )
          end
        end

      end
    end
  end
end
