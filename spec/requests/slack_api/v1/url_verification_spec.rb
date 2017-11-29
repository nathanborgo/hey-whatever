require_relative '../../../spec_helper'

describe "Slack API v1 Events" do
  it "should 401 if the slack event isn't verified" do
    post "/slack_api/v1/events", {
      token: "xxx",
      challenge: "yyy",
      type: "url_verification"
    }

    expect(status).to eq(401)
  end
end

