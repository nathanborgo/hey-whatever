require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'factory_bot'

ENV['RACK_ENV'] = 'test'

require_relative '../application.rb'
require_relative './helpers/slack_request_helper.rb'

module SpecHelper
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
  config.include SpecHelper
  config.include SlackRequestHelper
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    FactoryBot.find_definitions
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

