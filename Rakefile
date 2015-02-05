require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
Dir['lib/tasks/*.rake'].each { |rake| load rake }

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION > '1.9' && defined?(RUBY_ENGINE) && %w(rbx ruby).include?(RUBY_ENGINE)
  task default: %w(spec rubocop)
else
  task default: 'spec'
end
