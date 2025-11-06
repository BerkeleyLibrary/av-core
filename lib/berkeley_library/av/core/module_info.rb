# frozen_string_literal: true

module BerkeleyLibrary
  module AV
    module Core
      class ModuleInfo
        NAME = 'berkeley_library-av-core'
        AUTHORS = ['David Moles', 'maría a. matienzo'].freeze
        AUTHOR_EMAILS = ['dmoles@berkeley.edu', 'matienzo@berkeley.edu'].freeze
        SUMMARY = 'UC Berkeley Library audio/video core code'
        DESCRIPTION = 'Gem for UC Berkeley Library shared audio/video code'
        LICENSE = 'MIT'
        VERSION = '0.5.0'
        HOMEPAGE = 'https://github.com/BerkeleyLibrary/av-core'

        private_class_method :new
      end
    end
  end
end
