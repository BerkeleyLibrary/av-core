require 'marc'

module AV
  module Marc
    class << self
      # Parses MARCXML.
      #
      # @param xml [String] the XML to parse
      # @return [MARC::Record] the MARC record from the specified XML
      def from_xml(xml)
        input = StringIO.new(xml.scrub)
        # noinspection RubyYardReturnMatch
        MARC::XMLReader.new(input).first
      end
    end
  end
end
