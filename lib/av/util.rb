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

    class << self
      include AV::Util
    end
  end
end
