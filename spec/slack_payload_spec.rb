require_relative 'spec_helper.rb'

describe Slack::Payload do
  describe "#initialize" do
    it "should initialize a URL verification event" do
      request = '{
        "token": "xxx",
        "challenge": "yyTY5cemXZrxEVPsWIBlgkMnKcoYpbSMEkZdwJ45dP9GR5QXDiXc",
        "type": "url_verification"
      }'
      payload = Slack::Payload.new(request)

      payload.event.class.must_equal Slack::UrlVerification
    end

    it "should initialize a message event" do
      request = '{
        "event_time": "1509223537",
        "api_app_id": "A7RS13PLP",
        "event": {
          "text": "<@U3LADN8LA> testing self :taco: message",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        },
        "authed_users": [
          "U3LADN8LA"
        ],
        "team_id": "T3KKUHYNM",
        "event_id": "Ev7SCD1VK8",
        "token": "xxx",
        "type": "event_callback"
      }'
      payload = Slack::Payload.new(request)

      payload.event.class.must_equal Slack::Message
    end
  end
end

