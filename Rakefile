require "bundler/gem_tasks"

task :s do
  ruby './bin/rubrowser'
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end

