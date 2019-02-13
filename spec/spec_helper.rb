require "bundler/setup"

require 'simplecov'
SimpleCov.start

require "carraway"
require "rack/test"
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Carraway::Server
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpecMixin, type: :request

  config.before(:suite) do
    Carraway::Config.load('spec/test.yml')
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
