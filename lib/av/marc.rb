require 'marc'

module AV
  module Marc
    class << self
      # Parses MARCXML.
      #
      # @param xml [String] the XML to parse
      # @return [MARC::Record] the MARC record from the specified XML
      def from_xml(xml)
        # noinspection RubyYardReturnMatch
        all_from_xml(xml).first
      end

      # Parses MARCXML.
      #
      # @param xml [String] the XML to parse
      # @return [MARC::XMLReader] the MARC records
      def all_from_xml(xml)
        input = StringIO.new(xml.scrub)
        MARC::XMLReader.new(input)
      end
    end
  end
end
