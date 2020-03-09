module AV
  module Constants
    TAG_TITLE_FIELD = '245'.freeze
    TAG_LINK_FIELD = '856'.freeze
    TAG_TIND_CATALOG_ID = '901'.freeze
    TAG_TRACK_FIELD = '998'.freeze

    SUBFIELD_CODE_MILLENNIUM_ID = 'm'.freeze

    SUBFIELD_CODE_PATH = :g
    SUBFIELD_CODE_TITLE = :t
    SUBFIELD_CODE_DURATION = :a

    UNKNOWN_TITLE = 'Unknown title'.freeze

    RESTRICTIONS = ['UCB access', 'UCB only', 'Restricted to CalNet'].freeze
    RESTRICTIONS_NONE = 'Freely available'.freeze
  end
end
