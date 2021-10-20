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

    # rubocop:disable Metrics/CyclomaticComplexity
    def compare_by_attributes(v1, v2, *attrs)
      return 0 if v1.equal?(v2)
      return if v2.nil?

      attr_order = attrs.lazy.filter_map do |attr|
        return nil unless v2.respond_to?(attr)

        a1 = v1.send(attr)
        a2 = v2.send(attr)
        o = compare_values(a1, a2)
        o unless o.nil? || o == 0
      end.first

      attr_order || 0
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def compare_values(v1, v2)
      return 0 if v1 == v2
      return 1 if v1.nil?
      return -1 if v2.nil?
      # TODO: better array comparison
      return compare_values(v1.to_s, v2.to_s) unless v1.respond_to?(:<)

      v1 < v2 ? -1 : 1
    end

    def tidy_value(value)
      value && value.gsub(/[[:space:]]*-[[:space:]]*/, '-').strip
    end

    def class_name(t)
      return class_name(t.class) unless t.is_a?(Class) || t.is_a?(Module)

      t.name.sub(/^.*::/, '')
    end

    class << self
      include AV::Util
    end

  end
end
