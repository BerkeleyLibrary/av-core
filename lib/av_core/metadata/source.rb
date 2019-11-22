require 'typesafe_enum'

module AVCore
  module Metadata
    class Source < TypesafeEnum::Base
      new :TIND
      new :MILLENNIUM
    end
  end
end
