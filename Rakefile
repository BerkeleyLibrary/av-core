ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', __dir__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

# ------------------------------------------------------------
# Application code

File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

# ------------------------------------------------------------
# RSpec

require 'rspec/core/rake_task'

namespace :spec do
  desc 'Run all tests'
  RSpec::Core::RakeTask.new(:all) do |task|
    task.rspec_opts = %w[--color --format documentation --order default]
    task.pattern = 'spec/**/*_spec.rb'
  end
end

desc 'Run all tests'
task spec: 'spec:all'

# ------------------------------------------------------------
# Custom tasks

task default: 'cal:test:ci'
