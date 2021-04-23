lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubrowser/version'

Gem::Specification.new do |s|
  s.name        = 'rubrowser'
  s.version     = Rubrowser::VERSION
  s.authors     = ['Emad Elsaid']
  s.email       = ['emad.elsaid.hamed@gmail.com']
  s.homepage    = 'https://github.com/emad-elsaid/rubrowser'
  s.summary     = 'A ruby interactive dependency graph visualizer'
  s.description = 'A ruby interactive dependency graph visualizer'
  s.license     = 'MIT'
  s.required_ruby_version = '>=2.5'

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'litecable'
  s.add_runtime_dependency 'parser'
  s.add_runtime_dependency 'puma'
  s.add_runtime_dependency 'websocket'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
end
