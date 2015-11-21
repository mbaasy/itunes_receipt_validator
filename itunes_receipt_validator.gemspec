# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'itunes_receipt_validator/version'

Gem::Specification.new do |spec|
  spec.name = 'itunes_receipt_validator'
  spec.version = ItunesReceiptValidator::VERSION
  spec.summary = 'Validate iTunes OS X and iOS receipts'
  spec.description = <<-EOF
    Validate iTunes Transaction and Unified receipts
  EOF
  spec.license = 'MIT'
  spec.authors = ['mbaasy.com']
  spec.email = 'hello@mbaasy.com'
  spec.homepage = 'https://github.com/mbaasy/itunes_receipt_validator'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir['lib/**/*.rb'].reverse
  spec.require_paths = ['lib']

  spec.add_dependency 'itunes_receipt_decoder', '~> 0.2'

  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  spec.add_development_dependency 'rubocop', '~> 0.33'
end
