require 'rest-client'
require 'ucblit/logging'

module AV
  module Util
    include UCBLIT::Logging

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

    FAKE_CHROME_USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36'.freeze

    def get_or_raise(uri)
      resp = RestClient.get(uri.to_s, user_agent: FAKE_CHROME_USER_AGENT)
      begin
        return resp if resp.code == 200

        msg = "GET #{uri} failed; host returned #{resp.code}: #{resp.body || 'no response body'}"
        raise(RestClient::RequestFailed.new(resp, resp.code).tap { |ex| ex.message = msg })
      ensure
        logger.info("GET #{uri} returned #{resp.code}")
      end
    end
  end
end
