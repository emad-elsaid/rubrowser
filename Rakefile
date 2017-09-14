require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task :server do
  ruby './bin/rubrowser'
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

RSpec::Core::RakeTask.new(:spec)

task all: %I[spec rubocop] do
end

task default: :all
