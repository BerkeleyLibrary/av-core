module BerkeleyLibrary
  module AV
    module Constants
      TAG_TITLE_FIELD = '245'.freeze
      TAG_LINK_FIELD = '856'.freeze
      TAG_TRACK_FIELD = '998'.freeze
      TAG_TIND_ID = '001'.freeze
      TAG_TRANSCRIPT_FIELD = '856'.freeze

      SUBFIELD_CODE_URI = :u
      SUBFIELD_CODE_LINKTEXT = :y

      # TODO: use marc/spec
      TAG_TIND_CATALOG_ID = '901'.freeze
      SUBFIELD_CODE_TIND_BIB_NUMBER = 'm'.freeze

      # TODO: use marc/spec
      TAG_ALMA_MIGRATION_INFO = '996'.freeze
      SUBFIELD_CODE_ALMA_BIB_NUMBER = 'a'.freeze

      SUBFIELD_CODE_DURATION = :a
      SUBFIELD_CODE_TITLE = :t
      SUBFIELD_CODE_PATH = :g
      SUBFIELD_CODES_TRACKS = [SUBFIELD_CODE_DURATION, SUBFIELD_CODE_TITLE, SUBFIELD_CODE_PATH].freeze

      UNKNOWN_TITLE = 'Unknown title'.freeze

      # '99' is the Alma prefix for a Metadata Management System ID
      ALMA_RECORD_RE = /^(?<type>99)[0-9]{9,12}(?<institution>[0-9]{4})$/
      MILLENNIUM_RECORD_RE = /^b(?<digits>[0-9]{8})(?<check>[0-9ax])?$/
      OCLC_RECORD_RE = /^o[0-9]+$/
    end
  end
end
