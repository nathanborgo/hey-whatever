require 'sinatra/base'
require 'sinatra/activerecord'
require "sinatra/cookies"
require 'json'
require 'faraday'
require 'pry'
require 'dotenv/load'
require 'pp'
require 'date'
require 'bcrypt'

require_relative 'models/slack/payload.rb'
require_relative 'models/slack/url_verification.rb'
require_relative 'models/slack/message.rb'
require_relative 'models/taco.rb'
require_relative 'models/user.rb'


class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  helpers Sinatra::Cookies

  before do
    log_request_body
  end

  post "/slack_api/v1/events" do
    if !slack_event_verified?
      status 401
      return
    end

    if event.is_a?(Slack::UrlVerification)
      # https://api.slack.com/events/url_verification
      event.challenge
    elsif event.is_a?(Slack::Message) && event.gives_tacos?
      event.find_or_create_users
      event.assign_tacos
      status 202
    else
      puts "We don't know what this is"
      "We don't know what this is"
    end
  end

  post "/slack_api/v1/commands" do
    if !slack_event_verified?
      status 401
      return
    end

    current_user = User.find_by(slack_id: params["user_id"])
    today_taco_count = current_user.given_tacos.created_today.count
    leaderboard = []
    users = User.order(tacos_count: :desc).limit(10).each_with_index do |u, i|
      leaderboard << "#{i+1}. #{u.display_name}: #{u.tacos_count} tacos"
    end

    "*Top ten*\n#{leaderboard.join("\n")}\n<http://www.suptaco.com|View more...>\n\nYou have *#{current_user.tacos_count} tacos total* and *#{5 - today_taco_count} tacos left* to give out today."
  end

  post "/authorize" do
    cookies[:authorization_key] = BCrypt::Password.create(params[:secret_word])
    redirect '/'
  end

  get "/" do
    password = Rack::Utils.unescape(cookies[:authorization_key] || "")

    if password != "" && BCrypt::Password.new(password) == ENV["AUTHORIZATION_KEY"]
      @users = User.order(tacos_count: :desc)
      erb :leaderboard
    else
      erb :authorization
    end
  end

  after do
    ActiveRecord::Base.connection.close
  end

  helpers do
    def slack_conn
      @slack_conn ||= Faraday.new(url: "https://slack.com")
    end

    def request_body
      # Reading the body destroys it, apparently.
      @request_body ||= request.body.read
    end

    def event
      @event ||= Slack::Payload.new(request_body).event
    end

    def slack_event_verified?
      token = params["token"] || JSON.parse(request_body)["token"]
      token == ENV["SLACK_VERIFICATION_TOKEN"]
    end

    def log_request_body
      puts request_body if params[:verbose_request] == "true"
    end
  end
end
