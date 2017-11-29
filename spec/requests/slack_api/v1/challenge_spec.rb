require_relative '../../../spec_helper'

describe "Slack API v1 Events" do
  before do
    ENV["SLACK_VERIFICATION_TOKEN"] = "mock_token"
  end

  it "should respond with the slack challenge for verification" do
    post "/slack_api/v1/events", {
      token: "mock_token",
      challenge: "mock_challenge",
      type: "url_verification"
    }.to_json

    expect(status).to eq(200)
    expect(last_response.body).to eq("mock_challenge")
  end
end


