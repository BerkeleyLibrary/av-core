require 'typesafe_enum'
require 'av/constants'

module AV
  class RecordId
    # ------------------------------------------------------------
    # Constants

    ALMA_RE = AV::Constants::ALMA_RECORD_RE
    MILL_RE = AV::Constants::MILLENNIUM_RECORD_RE
    OCLC_RE = AV::Constants::OCLC_RECORD_RE

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
    # Class methods

    class << self
      def ensure_check_digit(bib_number)
        digit_str, check_str = split_bib(bib_number)

        digits = digit_str.chars.map(&:to_i)
        check_digit = calculate_check_digit(digits)

        return "b#{digit_str}#{check_digit}" if check_str.nil? || check_str == 'a'
        return bib_number if check_str == check_digit

        raise ArgumentError, "#{bib_number} check digit invalid: expected #{check_digit}, got #{check_str}"
      end

      private

      def split_bib(bib_number)
        raise ArgumentError, "Not a Millennium bib number: #{bib_number.inspect}" unless bib_number && (md = MILL_RE.match(bib_number))

        %i[digits check].map { |part| md[part] }
      end

      def calculate_check_digit(digits)
        raise ArgumentError, "Not an 8-digit array : #{digits.inspect}" unless digits.is_a?(Array) && digits.size == 8

        # From: http://liwong.blogspot.com/2018/04/recipe-computing-millennium-checkdigit.html
        mod = digits.reverse.each_with_index.inject(0) { |sum, (v, i)| sum + (v * (i + 2)) } % 11
        mod == 10 ? 'x' : mod.to_s
      end
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
          return Type::Alma if ALMA_RE =~ id_str
          return Type::Millennium if MILL_RE =~ id_str
          return Type::OCLC if OCLC_RE =~ id_str

          Type::TIND
        end
      end
    end
  end
end
