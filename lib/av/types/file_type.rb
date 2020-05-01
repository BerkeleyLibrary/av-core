require 'typesafe_enum'

module AV
  module Types
    class FileType < TypesafeEnum::Base

      new(:MP3, 'mp3') do
        def mime_type
          'application/x-mpegURL'
        end

        def player_tag
          'audio'
        end

        def label
          'Audio'
        end
      end

      new(:MP4, 'mp4') do
        def mime_type
          'video/mp4'
        end

        def player_tag
          'video'
        end

        def label
          'Video'
        end
      end

      new(:MOV, 'mov') do
        def mime_type
          'video/quicktime'
        end

        def player_tag
          'video'
        end

        def label
          'Video'
        end
      end

      def extension
        ".#{value}"
      end

      def to_s
        value.to_s
      end

      class << self
        # Returns the AV file type for the specified path
        #
        # @param path [String]
        # @return [AvFileType] The file type
        # @raise ArgumentError if the file type is not known or cannot be determined
        def for_path(path)
          raise ArgumentError, "Can't determine type of nil path" unless path

          FileType.each { |t| return t if path.end_with?(t.extension) }
          raise ArgumentError, "Unknown/unsupported file type: #{path}"
        end
      end
    end
  end
end
