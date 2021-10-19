module AV
  module Constants
    TAG_TITLE_FIELD = '245'.freeze
    TAG_LINK_FIELD = '856'.freeze
    TAG_TIND_CATALOG_ID = '901'.freeze
    TAG_TRACK_FIELD = '998'.freeze
    TAG_TIND_ID = '001'.freeze

    SUBFIELD_CODE_MILLENNIUM_ID = 'm'.freeze

    SUBFIELD_CODE_DURATION = :a
    SUBFIELD_CODE_TITLE = :t
    SUBFIELD_CODE_PATH = :g
    SUBFIELD_CODES_TRACKS = [SUBFIELD_CODE_DURATION, SUBFIELD_CODE_TITLE, SUBFIELD_CODE_PATH].freeze

    UNKNOWN_TITLE = 'Unknown title'.freeze

    RESTRICTIONS = ['UCB access', 'UCB only', 'Restricted to CalNet'].freeze
    RESTRICTIONS_NONE = 'Freely available'.freeze

    # '99' is the Alma prefix for a Metadata Management System ID
    ALMA_RECORD_RE = /^(?<type>99)[0-9]{9,11}(?<institution>[0-9]{4})$/
    MILLENNIUM_RECORD_RE = /^b(?<digits>[0-9]{8})(?<check>[0-9ax])?$/
    OCLC_RECORD_RE = /^o[0-9]+$/
  end
end
# https://avplayer.ucblib.org/music/b23161018
