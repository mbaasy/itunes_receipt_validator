if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'itunes_receipt_validator'
require_relative 'shared/shared_contexts'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
