module Slack
  class Message
    attr_reader :author_id, :text, :channel_id, :message_id, :event_ts

    def initialize(request)
      @author_id = request.dig("event", "user")
      @text = request.dig("event", "text")
      @channel_id = request.dig("event", "channel")
      @message_id = request.dig("event_id")
      @event_ts = request.dig("event", "event_ts")
    end

    def assign_tacos
      tacos = []
      taco_count.times do
        recipient_ids.each do |recipient_id|
          tacos << Taco.create(
            giver_id: author_id,
            recipient_id: recipient_id,
            message_id: message.id
          )
        end
      end
      return tacos
    end

    def find_or_create_users
      users = User.where(slack_id: involved_slack_ids)
      involved_slack_ids.each do |slack_id|
        filtered_users = users.select { |u| u.slack_id == slack_id }
        if !filtered_users.any?
          response = Faraday.new(url: 'https://slack.com').get("/api/users.info?token=#{ENV['SLACK_BOT_ACCESS_TOKEN']}&user=#{slack_id}")
          response_body = JSON.parse(response.body)
          if response_body.dig("ok")
            name = response_body.dig("user", "profile", "real_name")
            User.create(slack_id: slack_id, display_name: name)
          end
        end
      end
    end

    def gives_tacos?
      recipient_ids.count > 0 && taco_count > 0
    end

    private

    def message
      ::Message.where(channel_id: channel.id, ts: event_ts).first_or_create(text: text, user_id: author.id)
    end

    def author
      User.find_by(slack_id: author_id)
    end

    def channel
      Channel.where(slack_id: channel_id).first_or_create()
    end

    def involved_slack_ids
      [author_id] + recipient_ids
    end

    def recipient_ids
      @recipient_ids ||= text.scan(/<@(.*?)>/).flatten
    end

    def taco_count
      @taco_count ||= text.scan(/:taco:/).flatten.count
    end
  end
end
