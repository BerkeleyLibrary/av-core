require 'berkeley_library/util/uris'

module AV
  class Config
    REQUIRED_SETTINGS = %i[avplayer_base_uri millennium_base_uri tind_base_uri wowza_base_uri].freeze

    class << self

      # TODO: separate Config::Alma object?
      def alma_institution_id
        # UC Berkeley = 6532
        @alma_institution_id ||= value_from_rails_config(:alma_institution_id)
      end

      def alma_domain
        # UC Berkeley = berkeley.alma.exlibrisgroup.com
        @alma_domain ||= value_from_rails_config(:alma_domain)
      end

      def alma_institution_code
        # UC Berkeley = 01UCS_BER
        @alma_institution_code ||= value_from_rails_config(:alma_institution_code)
      end

      def alma_sru_base_uri
        @alma_base_uri ||= URIs.append("https://#{alma_domain}/view/sru/", alma_institution_code)
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
          settings = REQUIRED_SETTINGS
          settings.each do |setting|
            unset << setting unless set?(setting)
          end
        end
      end

      private

      # Returns a URI
      # @param [URI, String] url the base URL
      # @return [URI] the URI
      # @raise URI::InvalidURIError if the URI cannot be parsed, or is not HTTP/HTTPS
      def clean_uri(url)
        BerkeleyLibrary::Util::URIs.uri_or_nil(url).tap do |uri|
          raise URI::InvalidURIError, 'url cannot be nil' unless uri
          raise URI::InvalidURIError, 'URL must have a scheme' unless (scheme = uri.scheme)
          raise URI::InvalidURIError, 'URL must be HTTP or HTTPS' unless scheme.start_with?('http')
        end
      end

      def uri_from_rails_config(sym)
        return unless (config = rails_config)

        result = config.send(sym)
        clean_uri(result)
      end

      # Gets the specified value from the Rails configuraiton
      # @return [Object, nil] the value, or nil if there is no Rails configuration or the value is not set
      def value_from_rails_config(sym)
        rails_config.send(sym)
      end

      def rails_config
        return unless defined?(Rails)
        return unless (application = Rails.application)

        application.config
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
