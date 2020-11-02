require 'typesafe_enum'

module AV
  module Types
    class FileType < TypesafeEnum::Base

      # ############################################################
      # Non-enum constants

      # Supported extensions for MP3 files
      MP3_EXTENSIONS = ['.mp3'].freeze
      # Supported extensions for MP4 files, per https://www.wowza.com/docs/understanding-protocols-and-formats-supported-by-wowza-streaming-engine#supported-media-file-formats-for-vod-streaming
      MP4_EXTENSIONS = %w[.mp4 .f4v .mov .m4a .m4v .mp4a .mp4v .3gp .3g2].freeze

      # ############################################################
      # Initializer

      # rubocop:disable Metrics/ParameterLists
      def initialize(key, player_tag, mime_type, label: nil, prefix: nil, extensions: [])
        raise_if_duplicate(extensions)

        @player_tag = player_tag
        @mime_type = mime_type
        @label = label || player_tag.capitalize
        @prefix = prefix || key.to_s.downcase
        @extensions = extensions

        super(key)
      end

      # rubocop:enable Metrics/ParameterLists

      # ############################################################
      # Accessors and instance methods

      attr_reader :player_tag
      attr_reader :mime_type
      attr_reader :label
      attr_reader :prefix
      attr_reader :extensions

      def to_s
        value.to_s
      end

      private

      # ############################################################
      # Private methods

      def raise_if_duplicate(extensions)
        FileType.each do |t|
          next if (dups = extensions & t.extensions).empty?

          raise(ArgumentError, "#{FileType}::#{t.key} already covers extensions #{dups.join(', ')}") if t
        end
      end

      # ############################################################
      # Enum members

      new(:MP3, 'audio', 'application/x-mpegURL', extensions: MP3_EXTENSIONS)
      new(:MP4, 'video', 'video/mp4', extensions: MP4_EXTENSIONS)
      new(:UNKNOWN, 'object', 'application/octet-stream', label: 'Unknown')

      # ############################################################
      # Class methods

      class << self
        # Returns the AV file type for the specified path
        #
        # @param path [String]
        # @return [FileType] The file type, or FileType::UNKNOWN if the type cannot be determined
        def for_path(path)
          extension = path && File.extname(path)
          by_extension[extension] || FileType::UNKNOWN
        end

        def by_extension
          @by_extension ||= FileType.flat_map { |t| t.extensions.map { |x| [x, t] } }.to_h
        end

      end
    end
  end
end
