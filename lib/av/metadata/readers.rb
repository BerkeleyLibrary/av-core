require 'av/metadata/readers/millennium'
require 'av/metadata/readers/tind'

module AV
  class Metadata
    module Readers
      MILLENNIUM_RECORD_RE = /^b[0-9]{8}[0-9a-z]?$/
      OCLC_RECORD_RE = /^o[0-9]+$/

    end
  end
end
