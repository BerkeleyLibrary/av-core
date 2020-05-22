require 'rubocop'
require 'rubocop/rake_task'

desc 'Run rubocop with HTML output'
RuboCop::RakeTask.new(:rubocop) do |cop|
  output = ENV['RUBOCOP_OUTPUT'] || 'artifacts/reports/rubocop/index.html'

  cop.formatters = ['html']
  cop.options = ['--out', output]
end

desc 'Run RuboCop with auto-correct, and output results to console'
task :ra do
  # b/c we want console output, we can't just use `rubocop:auto_correct`
  RuboCop::CLI.new.run(['--auto-correct'])
end
