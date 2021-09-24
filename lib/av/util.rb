require 'rest-client'
require 'berkeley_library/logging'
require 'berkeley_library/util'
require 'av/core/module_info'

module AV
  module Util
    include BerkeleyLibrary::Logging
    include BerkeleyLibrary::Util

    DEFAULT_USER_AGENT = "#{Core::ModuleInfo::NAME} #{Core::ModuleInfo::VERSION} (#{Core::ModuleInfo::HOMEPAGE})".freeze

    def do_get(uri)
      URIs.get(uri, headers: { user_agent: DEFAULT_USER_AGENT })
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
