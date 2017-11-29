require_relative '../../../spec_helper'

describe "Slack API v1 Events" do
  before do
    ENV["SLACK_VERIFICATION_TOKEN"] = "mock_token"
  end

  it "ignores a message without any recognition" do
    post "/slack_api/v1/events", message_event(text: "Has anyone tried the enchiladas?")

    expect(status).to eq(200)
    expect(parsed_body["message"]).to eq("Ignoring non-recognition message.")
    expect(parsed_body["code"]).to eq("rgej392")
  end

  it "ignores a message with recognition but no tagged user" do
    post "/slack_api/v1/events", message_event(text: "Have a :taco:!")
    
    expect(status).to eq(200)
    expect(parsed_body["message"]).to eq("Ignoring non-recognition message.")
    expect(parsed_body["code"]).to eq("rgej392")
  end

  it "ignores a message with a tagged user but no recognition" do
    post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA>, check this out.")
    
    expect(status).to eq(200)
    expect(parsed_body["message"]).to eq("Ignoring non-recognition message.")
    expect(parsed_body["code"]).to eq("rgej392")
  end

  it "rewards tagged user with a taco" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: for being good.")
    }.to change{Taco.count}.from(0).to(1)

    taco = Taco.last
    
    expect(taco.giver_id).to eq("U3LADN8LD")
    expect(taco.recipient_id).to eq("U3LADN8LA")
    expect(taco.channel_id).to eq("C7RCLE8LT")
    expect(taco.message_id).to eq("Ev7SCD1VK8")
    expect(taco.given_at).to eq(1509223537.00001)
  end

  it "rewards tagged user with multiple tacos" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: :taco: :taco: for being extra good.")
    }.to change{Taco.count}.from(0).to(3)

    Taco.all.each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.recipient_id).to eq("U3LADN8LA")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end
  end

  it "rewards multiple tagged users with a taco" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco:")
    }.to change{Taco.count}.from(0).to(2)

    bill_taco = Taco.find_by(recipient_id: "U50LQDP6F")
    expect(bill_taco.giver_id).to eq("U3LADN8LD")
    expect(bill_taco.channel_id).to eq("C7RCLE8LT")
    expect(bill_taco.message_id).to eq("Ev7SCD1VK8")
    expect(bill_taco.given_at).to eq(1509223537.00001)

    frank_taco = Taco.find_by(recipient_id: "U7Q98PDEV")
    expect(frank_taco.giver_id).to eq("U3LADN8LD")
    expect(frank_taco.channel_id).to eq("C7RCLE8LT")
    expect(frank_taco.message_id).to eq("Ev7SCD1VK8")
    expect(frank_taco.given_at).to eq(1509223537.00001)
  end

  it "rewards multiple tagged users with multiple tacos" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco: :taco:")
    }.to change{Taco.count}.from(0).to(4)

    Taco.where(recipient_id: "U50LQDP6F").each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end

    Taco.where(recipient_id: "U7Q98PDEV").each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end
  end

  it "rewards tagged user with 5 tacos and then ignores the rest" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: :taco: :taco: :taco: :taco: :taco: :taco: :taco: for being illegally good.")
    }.to change{Taco.count}.from(0).to(5)

    Taco.all.each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.recipient_id).to eq("U3LADN8LA")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end
  end

  it "distributes tacos evenly over multiple tagged users" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco: :taco: :taco: :taco:")
    }.to change{Taco.count}.from(0).to(5)

    bill_tacos = Taco.where(recipient_id: "U50LQDP6F")
    expect(bill_tacos.count).to eq(3)
    bill_tacos.each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end

    frank_tacos = Taco.where(recipient_id: "U7Q98PDEV")
    expect(frank_tacos.count).to eq(2)
    frank_tacos.each do |taco|
      expect(taco.giver_id).to eq("U3LADN8LD")
      expect(taco.channel_id).to eq("C7RCLE8LT")
      expect(taco.message_id).to eq("Ev7SCD1VK8")
      expect(taco.given_at).to eq(1509223537.00001)
    end
  end
end

def message_event(text:)
  {
    token: "mock_token",
    team_id: "T3KKUHYNM",
    api_app_id: "A7RS13PLP",
    type: "event_callback",
    event_id: "Ev7SCD1VK8",
    event_time: "1509223537",
    authed_users: ["U3LADN8LD"],
    event: {
      type: "message",
      user: "U3LADN8LD",
      text: text,
      ts: "1509223537.000008",
      channel: "C7RCLE8LT",
      event_ts: "1509223537.000008"
    }
  }.to_json
end

