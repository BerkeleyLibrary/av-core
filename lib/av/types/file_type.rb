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

      new(:UNKNOWN, nil) do
        def mime_type
          'application/octet-stream'
        end

        def player_tag
          'object'
        end

        def label
          'Unknown'
        end

        def extension
          nil
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
        # @return [FileType] The file type, or FileType::UNKNOWN if the type cannot be determined
        def for_path(path)
          extension = path && File.extname(path)
          by_extension[extension] || FileType::UNKNOWN
        end

        def by_extension
          @by_extension ||= FileType.map { |t| [t.extension, t] }.to_h
        end
      end
    end
  end
end
