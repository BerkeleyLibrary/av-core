File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

ruby_version_file = File.expand_path('.ruby-version', __dir__)
ruby_version_exact = File.read(ruby_version_file).strip
ruby_minor_version = ruby_version_exact.gsub(/^(\d+\.\d+).*/, '\1')

require 'berkeley_library/av/core/module_info'

Gem::Specification.new do |spec|
  spec.name = BerkeleyLibrary::AV::Core::ModuleInfo::NAME
  spec.author = BerkeleyLibrary::AV::Core::ModuleInfo::AUTHOR
  spec.email = BerkeleyLibrary::AV::Core::ModuleInfo::AUTHOR_EMAIL
  spec.summary = BerkeleyLibrary::AV::Core::ModuleInfo::SUMMARY
  spec.description = BerkeleyLibrary::AV::Core::ModuleInfo::DESCRIPTION
  spec.license = BerkeleyLibrary::AV::Core::ModuleInfo::LICENSE
  spec.version = BerkeleyLibrary::AV::Core::ModuleInfo::VERSION
  spec.homepage = BerkeleyLibrary::AV::Core::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z -- ':!:Dockerfile' ':!:docker-compose.yml'`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = ">= #{ruby_minor_version}"

  spec.add_dependency 'berkeley_library-logging', '~> 0.2'
  spec.add_dependency 'berkeley_library-marc', '~> 0.2', '>= 0.2.1'
  spec.add_dependency 'berkeley_library-util', '~> 0.1', '>= 0.1.1'
  spec.add_dependency 'ruby-marc-spec', '~> 0.1', '>= 0.1.3'
  spec.add_dependency 'typesafe_enum', '~> 0.3'

  spec.add_development_dependency 'brakeman', '~> 4.9'
  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'irb', '~> 1.2' # workaroundfor https://github.com/bundler/bundler/issues/6929
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-support', '~> 3.9'
  spec.add_development_dependency 'rubocop', '1.26.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.8'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
