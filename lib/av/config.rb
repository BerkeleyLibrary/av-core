require 'berkeley_library/util/uris'

module AV
  # rubocop:disable Metrics/ClassLength
  class Config
    REQUIRED_SETTINGS = %i[
      avplayer_base_uri
      alma_sru_host
      alma_primo_host
      alma_institution_code
      alma_permalink_key
      millennium_base_uri
      tind_base_uri
      wowza_base_uri
    ].freeze

    class << self
      include BerkeleyLibrary::Util

      # Alma SRU hostname, e.g. UC Berkeley = berkeley.alma.exlibrisgroup.com
      def alma_sru_host
        @alma_sru_host ||= value_from_rails_config(:alma_sru_host)
      end

      # Alma institution code, e.g. UC Berkeley = 01UCS_BER
      def alma_institution_code
        @alma_institution_code ||= value_from_rails_config(:alma_institution_code)
      end

      # Alma Primo host, e.g. UC Berkeley = search.library.berkeley.edu
      def alma_primo_host
        @alma_primo_host ||= value_from_rails_config(:alma_primo_host)
      end

      # View state key to use when generating Alma permalinks, e.g. `iqob43`; see
      # https://knowledge.exlibrisgroup.com/Primo/Knowledge_Articles/What_is_the_key_in_short_permalinks%3F
      def alma_permalink_key
        @alma_permalink_key ||= value_from_rails_config(:alma_permalink_key)
      end

      def alma_sru_base_uri
        sru_base_uri_for(alma_sru_host, alma_institution_code)
      end

      def alma_permalink_base_uri
        primo_permalink_base_uri_for(alma_primo_host, alma_institution_code, alma_permalink_key)
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

      # Sets the Alma SRU hostname
      #
      # @param [String] hostname the hostname
      # @return [String] the hostname
      # @raise ArgumentError if the hostname is nil or empty
      # @raise URI::InvalidURIError if the resulting SRU URI cannot be parsed
      def alma_sru_host=(hostname)
        raise ArgumentError, "Invalid hostname: #{hostname.inspect}" if hostname.nil? || hostname.empty?

        sru_uri = sru_base_uri_for(hostname, '') # Catch bad URIs early
        @alma_sru_host = sru_uri.host
      end

      # Sets the Alma Primo hostname
      #
      # @param [String] hostname the hostname
      # @return [String] the hostname
      # @raise ArgumentError if the hostname is nil or empty
      # @raise URI::InvalidURIError if the resulting Primo permalink URI cannot be parsed
      def alma_primo_host=(hostname)
        raise ArgumentError, "Invalid hostname: #{hostname.inspect}" if hostname.nil? || hostname.empty?

        primo_uri = primo_permalink_base_uri_for(hostname, 'XXX', 'abc123') # Catch bad URIs early
        @alma_primo_host = primo_uri.host
      end

      # Sets the Alma SRU institution code
      #
      # @param [String] inst_code the institution code
      # @return [String] the institution code
      # @raise ArgumentError if the institution code is nil or empty
      # @raise URI::InvalidURIError if the resulting SRU URI cannot be parsed
      def alma_institution_code=(inst_code)
        raise ArgumentError, "Invalid institution code: #{inst_code.inspect}" if inst_code.nil? || inst_code.empty?

        sru_uri = sru_base_uri_for('example.org', inst_code) # Catch bad URIs early
        @alma_institution_code = sru_uri.path.split('/').last
      end

      # Sets the Alma permalink key
      #
      # @param [String] permalink_key the permalink key
      # @return [String] the permalink key
      # @raise ArgumentError if the permalink key is nil or empty
      # @raise URI::InvalidURIError if the resulting Primo permalink URI cannot be parsed
      def alma_permalink_key=(permalink_key)
        raise ArgumentError, "Invalid permalink key: #{permalink_key.inspect}" if permalink_key.nil? || permalink_key.empty?

        sru_uri = primo_permalink_base_uri_for('example.org', 'XXX', permalink_key) # Catch bad URIs early
        @alma_permalink_key = sru_uri.path.split('/').last
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

      def sru_base_uri_for(domain, inst_code)
        URIs.append("https://#{domain}/view/sru/", inst_code)
      end

      def primo_permalink_base_uri_for(alma_primo_host, inst_code, key)
        URIs.append("https://#{alma_primo_host}/", 'permalink', inst_code, key)
      end

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
        return unless (config = rails_config)

        config.send(sym)
      end

      def rails_config
        return unless defined?(Rails)
        return unless (application = Rails.application)

        application.config
      end

      def set?(setting)
        !Config.send(setting).nil?
      rescue NameError
        false
      end

      def clear!
        REQUIRED_SETTINGS.each do |attr|
          ivar_name = "@#{attr}"
          next unless instance_variable_defined?(ivar_name)

          send(:remove_instance_variable, ivar_name)
        end
      end
    end

    private_class_method :new

  end
  # rubocop:enable Metrics/ClassLength

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
