require 'sinatra/base'
require 'json'
require 'faraday'
require 'pry'
require 'dotenv/load'
require 'pp'
require 'sinatra/activerecord'

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  post '/slack_api/v1/events' do
    if !slack_event_verified?
      status 401
      return
    end

    if payload.dig("type") == "url_verification"
      puts "Accepting challenge."
      payload["challenge"]
    elsif payload.dig("event", "type") == "reaction_added" && payload.dig("event", "reaction") == "bomb"
      puts "About to blow!"
      BombWorker.perform_async(payload)
    else
      puts "Not a bomb"
      "Not a bomb."
    end
  end

  after do
    ActiveRecord::Base.connection.close
  end

  helpers do
    def slack_conn
      @slack_conn ||= Faraday.new(url: 'https://slack.com')
    end

    def payload
      @payload ||= JSON.parse(request.body.read)
    end

    def slack_event_verified?
      payload["token"] == ENV["SLACK_VERIFICATION_TOKEN"]
    end
  end
end
