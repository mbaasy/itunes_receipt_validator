# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'itunes_receipt_validator/version'

Gem::Specification.new do |spec|
  spec.name = 'itunes_receipt_validator'
  spec.version = ItunesReceiptValidator::VERSION
  spec.summary = 'Validate iTunes OS X and iOS receipts'
  spec.description = <<-EOF
    Validate iTunes Transaction and Unified style receipts with local decoding
    and remote validation.
  EOF
  spec.license = 'MIT'
  spec.authors = ['mbaasy.com']
  spec.email = 'hello@mbaasy.com'
  spec.homepage = 'https://github.com/mbaasy/itunes_receipt_validator'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir['lib/**/*.rb'].reverse
  spec.require_paths = ['lib']

  spec.add_dependency 'itunes_receipt_decoder', '0.3.1'

  spec.add_development_dependency 'rake', '~> 10.5'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  spec.add_development_dependency 'rubocop', '~> 0.37'
  spec.add_development_dependency 'webmock', '~> 1.24'
  spec.add_development_dependency 'timecop', '0.8'
end
