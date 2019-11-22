require 'typesafe_enum'

module AvPlayer
  module Core
    module Metadata
      class Source < TypesafeEnum::Base
        new :TIND
        new :MILLENNIUM
      end
    end
  end
end
