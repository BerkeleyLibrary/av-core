require 'typesafe_enum'
require 'av/constants'

module AV
  class RecordId
    include AV::Util
    include Comparable

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
      def ensure_record_id(record_id)
        return record_id if record_id.is_a?(RecordId)

        RecordId.new(record_id)
      end

      def ensure_check_digit(bib_number)
        digit_str, check_str = split_bib(bib_number)

        digits = digit_str.chars.map(&:to_i)
        check_digit = calculate_check_digit(digits)

        return "b#{digit_str}#{check_digit}" if check_str.nil? || check_str == 'a'
        return bib_number if check_str == check_digit

        raise ArgumentError, "#{bib_number} check digit invalid: expected #{check_digit}, got #{check_str}"
      end

      def strip_check_digit(bib_number)
        digit_str, = split_bib(bib_number)
        "b#{digit_str}"
      end

      private

      def split_bib(bib_number)
        raise ArgumentError, "Not a MILLENNIUM bib number: #{bib_number.inspect}" unless bib_number.is_a?(String) && (md = MILL_RE.match(bib_number))

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
    # Comparable

    def <=>(other)
      compare_by_attributes(self, other, :id, :type)
    end

    # ------------------------------------------------------------
    # Object overrides

    def hash
      [id, type].hash
    end

    def to_s
      id
    end

    def inspect
      "#{self.class}(#{id} [#{type}])@#{object_id}"
    end

    # ------------------------------------------------------------
    # Helper classes

    class Type < TypesafeEnum::Base
      new :ALMA
      new :MILLENNIUM
      new :OCLC
      new :TIND

      def to_s
        key.to_s
      end

      class << self
        def for_id(id_str)
          return unless id_str
          return Type::ALMA if ALMA_RE =~ id_str
          return Type::MILLENNIUM if MILL_RE =~ id_str
          return Type::OCLC if OCLC_RE =~ id_str

          Type::TIND
        end
      end
    end
  end
end
