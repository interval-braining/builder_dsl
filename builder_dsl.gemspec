# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'builder_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = 'builder_dsl'
  spec.version       = BuilderDSL::VERSION
  spec.authors       = ['Danny Guinther']
  spec.email         = ['dannyguinther@gmail.com']
  spec.summary       = %q{Builder DSL}
  spec.description   = %q{Simple DSL for defining Object builders}
  spec.homepage      = 'https://github.com/interval-braining/builder_dsl'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
