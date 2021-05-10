require 'typesafe_enum'

module AV
  class RecordId
    # ------------------------------------------------------------
    # Constants

    ALMA_RE = /^[0-9]{15,17}$/
    MILL_RE = /^b[0-9]{8}[0-9a-z]?$/
    OCLC_RE = /^o[0-9]+$/

    # ------------------------------------------------------------
    # Fields

    attr_reader :id, :type

    # ------------------------------------------------------------
    # Initializer

    def initialize(id)
      @id = id.to_s
      @type = Type.for_id(@id)
    end

    # ------------------------------------------------------------
    # Object overrides

    def eql?(other)
      self.class == other.class &&
        id == other.id &&
        type == other.type
    end
    alias :== eql?

    def hash
      [id, type].hash
    end

    def to_s
      "#{type}:#{id}"
    end

    def inspect
      "#{self.class}(#{id} [#{type}])@#{object_id}"
    end

    # ------------------------------------------------------------
    # Helper classes

    class Type < TypesafeEnum::Base
      new :Alma
      new :Millennium
      new :OCLC
      new :TIND

      def to_s
        key.to_s
      end

      class << self
        def for_id(id_str)
          return unless id_str
          return Type::Alma if ALMA_RE =~ id_str && id_str.ends_with?(AV::Config.alma_institution_id)
          return Type::Millennium if MILL_RE =~ id_str
          return Type::OCLC if OCLC_RE =~ id_str

          Type::TIND
        end
      end
    end
  end
end
