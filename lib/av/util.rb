require 'av/logger'

module AV
  module Util
    def log
      AV.logger
    end

    def do_get(uri)
      resp = RestClient.get(uri.to_s)
      if resp.code != 200
        log.error("GET #{uri} returned #{resp.code}: #{resp.body || 'nil'}")
        raise(RestClient::RequestFailed.new(resp, resp.code).tap do |ex|
          ex.message = "GET #{uri} failed; host returned #{resp.code}"
        end)
      end
      body = resp.body
      body && body.scrub
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

    class << self
      include AV::Util
    end
  end
end
