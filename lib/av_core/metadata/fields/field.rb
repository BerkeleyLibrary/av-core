module AVCore
  module Metadata
    module Fields
      class Field
        LINK_FIELD_TAG = '856'.freeze
        TRACK_FIELD_TAG = '998'.freeze

        attr_reader :tag
        attr_reader :label

        def initialize(tag:, label:)
          @tag = tag
          @label = label
        end

        class << self
          def from_subfield_values(all_subfield_values, tag:, label:, subfields_separator:)
            case tag
            when LINK_FIELD_TAG
              LinkField.from_subfield_values(all_subfield_values, tag: tag, label: label)
            when TRACK_FIELD_TAG
              TrackField.from_subfield_values(all_subfield_values, tag: tag, label: label)
            else
              TextField.from_subfield_values(all_subfield_values, tag: tag, label: label, subfields_separator: subfields_separator)
            end
          end
        end
      end
    end
  end
end
