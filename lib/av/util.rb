require 'av/logger'
require 'rest-client'

module AV
  module Util
    def log
      AV.logger
    end

    def do_get(uri, ignore_errors: false)
      resp = get_or_raise(uri)
      body = resp.body
      body && body.scrub
    rescue RestClient::Exception
      raise unless ignore_errors
    end

    def compare_values(v1, v2)
      return 0 if v1 == v2
      return 1 if v1.nil?
      return -1 if v2.nil?

      v1 < v2 ? -1 : 1
    end

    def tidy_value(value)
      value && value.gsub(/[[:space:]]*-[[:space:]]*/, '-').strip
    end

    def uri_or_nil(url)
      return unless url
      return url if url.is_a?(URI)

      URI.parse(url)
    end

    class << self
      include AV::Util
    end

    private

    def get_or_raise(uri)
      resp = RestClient.get(uri.to_s)
      begin
        return resp if resp.code == 200

        msg = "GET #{uri} failed; host returned #{resp.code}: #{resp.body || 'no response body'}"
        raise(RestClient::RequestFailed.new(resp, resp.code).tap { |ex| ex.message = msg })
      ensure
        log.info("GET #{uri} returned #{resp.code}")
      end
    end
  end
end
