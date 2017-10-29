require_relative '../../spec_helper'

include Rack::Test::Methods

describe Slack::Payload do
  describe "initialize" do
    it "creates a URL verification event" do
      request = '{"token": "XAVL8y1bK6ZTEFRrt6giklQY","challenge": "yyTY5cemXZrxEVPsWIBlgkMnKcoYpbSMEkZdwJ45dP9GR5QXDiXc","type": "url_verification"}'
      payload = Slack::Payload.new(request)

      binding.pry
    end

    it "creates a message event" do

    end
  end
end

