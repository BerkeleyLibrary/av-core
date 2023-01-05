require 'marc'

module AV
  module Marc
    class << self
      # Parses MARCXML.
      #
      # @param xml [String] the XML to parse
      # @return [MARC::Record, nil] the MARC record from the specified XML
      def from_xml(xml)
        # noinspection RubyYardReturnMatch,RubyMismatchedReturnType
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

      # Returns a reader for the specified MARC file.
      #
      # @param marc_path [String] the path to a MARC file in XML or binary format
      # @param external_encoding [String] the encoding, for binary files
      # @return [MARC::XMLReader] if the file path ends in `.xml`
      # @return [MARC::Reader] if the file path ends in `.mrc`
      def reader_for(marc_path, external_encoding: 'MARC-8')
        downcased_path = marc_path.downcase
        return MARC::XMLReader.new(marc_path) if downcased_path.end_with?('.xml')
        return MARC::Reader.new(marc_path, external_encoding:) if downcased_path.end_with?('.mrc')

        raise ArgumentError, "Unable to determine reader needed for MARC file #{marc_path.inspect}"
      end

      # Returns a MARC record read from the specified file (or the first record
      # if the file contains multiple records).
      #
      # @param marc_path [String] the path to a MARC file in XML or binary format
      # @param external_encoding [String] the encoding, for binary files
      # @return [MARC::Record] the MARC record
      def read(marc_path, external_encoding: 'MARC-8')
        # noinspection RubyYardReturnMatch
        reader_for(marc_path, external_encoding:).first
      end
    end
  end
end
