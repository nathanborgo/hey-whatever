require_relative 'spec_helper.rb'

describe Slack::Message do
  before do
    # Whatever.
    Taco.destroy_all
  end

  after do
    Taco.destroy_all
  end

  describe "#initialize" do
    let(:parsed_request) do
      JSON.parse('{
        "event": {
          "text": "<@U3LADN8LA> testing self :taco: message",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }')
    end

    it "should initialize an author_id attribute" do
      event = Slack::Message.new(parsed_request)

      event.author_id.must_equal "U3LADN8LA"
    end

    it "should initialize a text attribute" do
      event = Slack::Message.new(parsed_request)

      event.text.must_equal "<@U3LADN8LA> testing self :taco: message"
    end

    it "should initialize a channel_id attribute" do
      event = Slack::Message.new(parsed_request)

      event.channel_id.must_equal "C7RCLE8LT"
    end
  end

  describe "gives_tacos?" do
    it "should give tacos when there are recipients and tacos" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "<@U3LADN8LA> testing self :taco: message",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))

      event.gives_tacos?.must_equal true
    end

    it "should not give tacos when there are tacos and no recipients" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "i figured out this emoji :taco:",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))

      event.gives_tacos?.must_equal false
    end

    it "should not give tacos when there are recipients and no tacos" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "hey <@U3LADN8LA> check out this thing",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))

      event.gives_tacos?.must_equal false
    end

    it "should not give tacos when there are neither recipients nor tacos" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "this is a totally unrelated message",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))

      event.gives_tacos?.must_equal false
    end
  end

  describe "#assign_tacos" do
    it "assigns 1 taco to 1 person" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "<@U3LADN8LB> testing self :taco: message",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))
      event.assign_tacos

      taco = Taco.find_by(giver_id: "U3LADN8LA")

      Taco.count.must_equal 1
      taco.giver_id.must_equal "U3LADN8LA"
      taco.recipient_id.must_equal "U3LADN8LB"
      taco.original_text.must_equal "<@U3LADN8LB> testing self :taco: message"
    end

    it "assigns 2 tacos to 1 person" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "<@U3LADN8LB> :taco: :taco:",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))
      event.assign_tacos

      tacos = Taco.where(recipient_id: "U3LADN8LB")

      Taco.count.must_equal 2
      tacos.count.must_equal 2
      tacos.each do |taco|
        taco.giver_id.must_equal "U3LADN8LA"
        taco.original_text.must_equal "<@U3LADN8LB> :taco: :taco:"
      end
    end

    it "assigns 1 taco to 2 people" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "<@U3LADN8LB> <@U3LADN8LC> :taco:",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))
      event.assign_tacos

      taco_b = Taco.find_by(recipient_id: "U3LADN8LB")
      taco_c = Taco.find_by(recipient_id: "U3LADN8LC")

      Taco.count.must_equal 2
      taco_b.present?.must_equal true
      taco_b.giver_id.must_equal "U3LADN8LA"
      taco_b.original_text.must_equal "<@U3LADN8LB> <@U3LADN8LC> :taco:"
      taco_c.present?.must_equal true
      taco_c.giver_id.must_equal "U3LADN8LA"
      taco_c.original_text.must_equal "<@U3LADN8LB> <@U3LADN8LC> :taco:"
    end

    it "assigned 2 tacos to 2 people" do
      event = Slack::Message.new(JSON.parse('{
        "event": {
          "text": "<@U3LADN8LB> <@U3LADN8LC> :taco: :taco:",
          "ts": "1509223537.000008",
          "channel": "C7RCLE8LT",
          "type": "message",
          "event_ts": "1509223537.000008",
          "user": "U3LADN8LA"
        }
      }'))
      event.assign_tacos

      tacos_b = Taco.where(recipient_id: "U3LADN8LB")
      tacos_c = Taco.where(recipient_id: "U3LADN8LC")

      Taco.count.must_equal 4
      [tacos_b, tacos_c].each do |tacos|
        tacos.count.must_equal 2
        tacos.each do |taco|
          taco.giver_id.must_equal "U3LADN8LA"
          taco.original_text.must_equal "<@U3LADN8LB> <@U3LADN8LC> :taco: :taco:"
        end
      end
    end
  end
end

