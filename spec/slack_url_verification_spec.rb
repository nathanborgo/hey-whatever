require_relative 'spec_helper.rb'

describe Slack::UrlVerification do
  describe "#initialize" do
    it "should have an accessible challenge attribute" do
      request = JSON.parse('{
        "token": "xxx",
        "challenge": "yyy",
        "type": "url_verification"
      }')
      event = Slack::UrlVerification.new(request)

      event.challenge.must_equal "yyy"
    end
  end
end


