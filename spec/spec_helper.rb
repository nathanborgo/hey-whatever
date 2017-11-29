require 'rack/test'
require 'rspec'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'

require_relative '../application.rb'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Application
  end

  def parsed_body
    JSON.parse(last_response.body)
  end

  def status
    last_response.status
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

