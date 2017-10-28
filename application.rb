require 'sinatra/base'
require 'json'
require 'faraday'
require 'pry'
require 'dotenv/load'
require 'pp'
require 'sinatra/activerecord'

require_relative 'models/slack/payload.rb'
require_relative 'models/slack/url_verification.rb'
require_relative 'models/slack/message.rb'
require_relative 'models/taco.rb'

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  before do
    log_request_body
  end

  post '/slack_api/v1/events' do
    if !slack_event_verified?
      status 401
      return
    end

    if event.is_a?(Slack::UrlVerification)
      # https://api.slack.com/events/url_verification
      event.challenge
    elsif event.is_a?(Slack::Message) && event.gives_tacos?
      event.assign_tacos
    else
      puts "We don't know what this is"
      "We don't know what this is"
    end
  end

  after do
    ActiveRecord::Base.connection.close
  end

  helpers do
    def slack_conn
      @slack_conn ||= Faraday.new(url: 'https://slack.com')
    end

    def request_body
      # Reading the body destroys it, apparently.
      @request_body ||= request.body.read
    end

    def event
      @event ||= Slack::Payload.new(request_body).event
    end

    def slack_event_verified?
      JSON.parse(request_body)["token"] == ENV["SLACK_VERIFICATION_TOKEN"]
    end

    def log_request_body
      puts request_body if params[:verbose_request] == "true"
    end
  end
end
