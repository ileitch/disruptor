begin
  require 'rubocop/rake_task'
  t = RuboCop::RakeTask.new
  t.options << '-D'
rescue LoadError
  warn 'rubocop not available.'
  task rubocop: []
end
