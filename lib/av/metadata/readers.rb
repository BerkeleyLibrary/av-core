require 'av/metadata/readers/alma'
require 'av/metadata/readers/millennium'
require 'av/metadata/readers/tind'

module AV
  class Metadata
    module Readers
      # TODO: remove these
      MILLENNIUM_RECORD_RE = /^b[0-9]{8}[0-9a-z]?$/
      # TODO: remove these
      OCLC_RECORD_RE = /^o[0-9]+$/

    end
  end
end
