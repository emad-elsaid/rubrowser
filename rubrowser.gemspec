$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rubrowser'

Gem::Specification.new do |s|
  s.name        = 'rubrowser'
  s.version     = Rubrowser::VERSION
  s.authors     = ['Emad Elsaid']
  s.email       = ['blazeeboy@gmail.com']
  s.homepage    = 'https://github.com/blazeeboy/rubrowser'
  s.summary     = 'a ruby code dependency graph interactive visualizer'
  s.description = 'a ruby code dependency graph interactive visualizer'
  s.license     = 'MIT'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['../lib']
  s.executables << 'rubrowser'

  s.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.0'
  s.add_runtime_dependency 'parser', '~> 2.3', '>= 2.3.0'
  s.add_runtime_dependency 'parallel', '~> 1.9', '>= 1.9.0'
  s.add_runtime_dependency 'haml', '~> 4.0', '>= 4.0.0'
end
