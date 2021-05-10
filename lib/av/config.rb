require 'uri'

module AV

  class Config
    class << self
      DEFAULT_ALMA_INSTITUTION_ID = '6532'.freeze

      def alma_institution_id
        @alma_institution_id ||= (value_from_rails_config(:alma_institution_id) || 6532)
      end

      def avplayer_base_uri
        @avplayer_base_uri ||= uri_from_rails_config(:avplayer_base_uri)
      end

      def millennium_base_uri
        @millennium_base_uri ||= uri_from_rails_config(:millennium_base_uri)
      end

      def tind_base_uri
        @tind_base_uri ||= uri_from_rails_config(:tind_base_uri)
      end

      def wowza_base_uri
        @wowza_base_uri ||= uri_from_rails_config(:wowza_base_uri)
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

      # Sets the Wowza base URI
      #
      # @param [URI, String] uri the base URI
      # @return [URI] the URI
      # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
      def wowza_base_uri=(uri)
        @wowza_base_uri = clean_uri(uri)
      end

      # Returns the list of missing required settings.
      # @return [Array<Symbol>] the missing settings.
      def missing
        [].tap do |unset|
          settings = %i[avplayer_base_uri millennium_base_uri tind_base_uri wowza_base_uri]
          settings.each do |setting|
            unset << setting unless set?(setting)
          end
        end
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

      def value_from_rails_config(sym)
        return unless defined?(Rails)
        return unless (application = Rails.application)
        return unless (config = application.config)

        config.send(sym)
      end

      def uri_from_rails_config(sym)
        raise ArgumentError, "Rails.application.#{sym} not set" unless (val = value_from_rails_config(sym))

        clean_uri(val)
      end

      def set?(setting)
        Config.send(setting) && true
      rescue NameError
        false
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

    def configured?
      Config.missing.empty?
    end
  end
end
