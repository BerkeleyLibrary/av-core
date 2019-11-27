File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'av/core/module_info'

Gem::Specification.new do |spec|
  spec.name = AV::Core::ModuleInfo::NAME
  spec.author = AV::Core::ModuleInfo::AUTHOR
  spec.email = AV::Core::ModuleInfo::AUTHOR_EMAIL
  spec.summary = AV::Core::ModuleInfo::SUMMARY
  spec.description = AV::Core::ModuleInfo::DESCRIPTION
  spec.license = AV::Core::ModuleInfo::LICENSE
  spec.version = AV::Core::ModuleInfo::VERSION
  spec.homepage = AV::Core::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'marc', '~> 1.0'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'typesafe_enum', '~> 0.1.9'

  spec.add_development_dependency 'brakeman'
  spec.add_development_dependency 'bundle-audit'
  spec.add_development_dependency 'ci_reporter_rspec'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'irb' # workaroundfor https://github.com/bundler/bundler/issues/6929
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'rake', '>= 13.0'
  spec.add_development_dependency 'rspec-support'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'webmock'
end
