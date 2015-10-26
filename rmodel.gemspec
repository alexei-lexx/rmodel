# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rmodel/version'

Gem::Specification.new do |spec|
  spec.name          = 'rmodel'
  spec.version       = Rmodel::VERSION
  spec.authors       = ['Alexei']
  spec.email         = ['alexei.lexx@gmail.com']
  spec.summary       = %q{Rmodel is an ORM library, which tends to follow the SOLID principles.}
  spec.description   = %q{Rmodel is an ORM library, which tends to follow the SOLID principles.}
  spec.homepage      = 'https://github.com/alexei-lexx/rmodel'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mongo', '~> 2.1'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'origin'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.required_ruby_version = '>= 2.0.0'
end
