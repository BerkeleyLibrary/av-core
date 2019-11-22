require 'rubocop/rake_task'

desc 'Run rubocop with HTML output'
RuboCop::RakeTask.new(:rubocop) do |cop|
  output = ENV['RUBOCOP_OUTPUT'] || 'spec/reports/rubocop/index.html'

  cop.formatters = ['html']
  cop.options = ['--out', output]
end
