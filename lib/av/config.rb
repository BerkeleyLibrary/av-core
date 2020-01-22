require 'uri'

module AV

  class Config
    class << self
      def avplayer_base_uri
        @avplayer_base_uri ||= uri_from_rails_config(:avplayer_base_uri)
      end

      def millennium_base_uri
        @millennium_base_uri ||= uri_from_rails_config(:millennium_base_uri)
      end

      def tind_base_uri
        @tind_base_uri ||= uri_from_rails_config(:tind_base_uri)
      end

      # Sets the AV Player base URI
      #
      # @param [URI, String] uri the base URI
      # @return [URI] the URI
      # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
      def avplayer_base_uri=(uri)
        @avplayer_base_uri = clean_uri(uri)
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
        raise NameError, "Can't read #{sym.inspect} from Rails config: Rails is not defined" unless defined?(Rails)

        application = Rails.application
        raise ArgumentError, "Can't read #{sym.inspect} from Rails config: Rails.application is nil" unless application

        config = Rails.application.config
        raise ArgumentError, "Can't read #{sym.inspect} from Rails config: Rails.application.config is nil" unless application

        result = config.send(sym)
        clean_uri(result)
      end
    end

    private_class_method :new

  end

  class << self
    def config
      AV::Config
    end

    def configure(&block)
      class_eval(&block)
    end
  end

end
