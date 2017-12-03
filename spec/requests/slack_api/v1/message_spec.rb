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
    
    expect(taco.giver_id).to eq("U7RD3CCF6")
    expect(taco.recipient_id).to eq("U3LADN8LA")
    expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
    expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
  end

  it "rewards tagged user with multiple tacos" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: :taco: :taco: for being extra good.")
    }.to change{Taco.count}.from(0).to(3)

    Taco.all.each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.recipient_id).to eq("U3LADN8LA")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end
  end

  it "rewards multiple tagged users with a taco" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco:")
    }.to change{Taco.count}.from(0).to(2)

    bill_taco = Taco.find_by(recipient_id: "U50LQDP6F")
    expect(bill_taco.giver_id).to eq("U7RD3CCF6")
    expect(bill_taco.message.channel.slack_id).to eq("C7RCLE8LT")
    expect(bill_taco.message.ts).to be_within(0.001).of(1509223537.000008)

    frank_taco = Taco.find_by(recipient_id: "U7Q98PDEV")
    expect(frank_taco.giver_id).to eq("U7RD3CCF6")
    expect(frank_taco.message.channel.slack_id).to eq("C7RCLE8LT")
    expect(frank_taco.message.ts).to be_within(0.001).of(1509223537.000008)
  end

  it "rewards multiple tagged users with multiple tacos" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco: :taco:")
    }.to change{Taco.count}.from(0).to(4)

    Taco.where(recipient_id: "U50LQDP6F").each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end

    Taco.where(recipient_id: "U7Q98PDEV").each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end
  end

  it "rewards tagged user with 5 tacos and then ignores the rest" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: :taco: :taco: :taco: :taco: :taco: :taco: :taco: for being illegally good.")
    }.to change{Taco.count}.from(0).to(5)

    Taco.all.each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.recipient_id).to eq("U3LADN8LA")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end
  end

  it "distributes tacos evenly over multiple tagged users" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U50LQDP6F> <@U7Q98PDEV> :taco: :taco: :taco: :taco:")
    }.to change{Taco.count}.from(0).to(5)

    bill_tacos = Taco.where(recipient_id: "U50LQDP6F")
    expect(bill_tacos.count).to eq(3)
    bill_tacos.each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end

    frank_tacos = Taco.where(recipient_id: "U7Q98PDEV")
    expect(frank_tacos.count).to eq(2)
    frank_tacos.each do |taco|
      expect(taco.giver_id).to eq("U7RD3CCF6")
      expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
      expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    end
  end

  it "creates and assigns respective users from a message" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: for being good.")
    }.to change{Taco.count}.from(0).to(1)

    taco = Taco.last

    expect(taco.giver.slack_id).to eq("U7RD3CCF6")
    expect(taco.giver.display_name).to eq("Molly")
    expect(taco.giver.tacos_count).to eq(0)

    expect(taco.recipient.slack_id).to eq("U3LADN8LA")
    expect(taco.recipient.display_name).to eq("Nathan Borgo")
    expect(taco.recipient.tacos_count).to eq(1)
  end

  it "creates and assigns message objects from a slack message" do
    expect {
      post "/slack_api/v1/events", message_event(text: "<@U3LADN8LA> :taco: for being good.")
    }.to change{Taco.count}.from(0).to(1)

    taco = Taco.last

    expect(taco.message.user.slack_id).to eq("U7RD3CCF6")
    expect(taco.message.channel.slack_id).to eq("C7RCLE8LT")
    expect(taco.message.ts).to be_within(0.001).of(1509223537.000008)
    expect(taco.message.text).to eq("<@U3LADN8LA> :taco: for being good.")
    # expect(taco.message.permalink).to eq()
  end
end


