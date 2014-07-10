# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'building_blocks/version'

Gem::Specification.new do |spec|
  spec.name          = 'building_blocks'
  spec.version       = BuildingBlocks::VERSION
  spec.authors       = ['Danny Guinther']
  spec.email         = ['dannyguinther@gmail.com']
  spec.summary       = %q{Building Blocks}
  spec.description   = %q{Simple DSL for defining Object builders}
  spec.homepage      = 'https://github.com/interval-braining/building_blocks'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
