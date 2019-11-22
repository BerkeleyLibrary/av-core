require 'uri'

module AVCore
  module Metadata
    module Config
      class << self
        def base_uri_for(source)
          return millennium_base_uri if source == Source::MILLENNIUM
          return tind_base_uri if source == Source::TIND

          raise ArgumentError, "Unsupported metadata source: #{source || 'nil'}"
        end

        def millennium_base_uri
          @millennium_base_uri ||= uri_from_rails_config(:millennium_base_uri)
        end

        def tind_base_uri
          @tind_base_uri ||= uri_from_rails_config(:tind_base_uri)
        end

        # Sets the Millennium base URI
        #
        # @param [URI, String] uri the base URI
        # @return [URI] the URI
        # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
        def millennium_base_uri=(uri)
          @millennium_base_uri = clean_uri(uri)
        end

        # Sets the TIND base URI
        #
        # @param [URI, String] uri the base URI
        # @return [URI] the URI
        # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
        def tind_base_uri=(uri)
          @tind_base_uri = clean_uri(uri)
        end

        private

        # Returns a URI, with any trailing slash removed to simplify
        # concatenation
        # @param [URI, String] url the base URL
        # @return [URI] the URI
        # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
        def clean_uri(url)
          uri = url.is_a?(URI) ? url : URI.parse(url)

          uri.scheme.tap do |scheme|
            raise URI::InvalidURIError, 'URL must have a scheme' unless scheme
            raise URI::InvalidURIError, 'URL must be HTTP or HTTPS' unless scheme.start_with?('http')
          end

          uri.tap { |u| u.path.delete_suffix('/') }
        end

        def uri_from_rails_config(sym)
          raise NameError, 'Rails is not defined' unless defined?(Rails)

          application = Rails.application
          raise ArgumentError, 'Rails.application is nil' unless application

          config = Rails.application.config
          raise ArgumentError, 'Rails.application.config is nil' unless application

          result = config.send(sym)
          clean_uri(result)
        end
      end
    end
  end
end
