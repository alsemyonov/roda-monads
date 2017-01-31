# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/monads/version'

Gem::Specification.new do |spec|
  spec.name = 'roda-monads'
  spec.version = Roda::Monads::VERSION
  spec.authors = ['Alex Semyonov']
  spec.email = ['alex@semyonov.us']

  spec.summary = 'Roda matchers for DRY::Monads'
  spec.description = 'Reuse business logic operations in Roda'
  spec.homepage = 'http://alsemyonov.gitlab.com/roda-monads/'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'roda', '~> 2.21.0'
  spec.add_runtime_dependency 'dry-monads', '~> 0.2.1'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'bundler-audit', '~> 0.5.0'
  spec.add_development_dependency 'rack-test', '~> 0.6.3'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec-roda', '~> 0.1.0'
  spec.add_development_dependency 'rubocop', '~> 0.47.0'
  spec.add_development_dependency 'simplecov', '~> 0.12.0'
  spec.add_development_dependency 'yard', '~> 0.9.5'
end
