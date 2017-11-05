module Slack
  class Message
    attr_reader :author_id, :text, :channel_id, :message_id, :given_at

    def initialize(request)
      @author_id = request.dig("event", "user")
      @text = request.dig("event", "text")
      @channel_id = request.dig("event", "channel")
      @message_id = request.dig("event_id")
      @given_at = request.dig("event", "event_ts")
    end

    def assign_tacos
      tacos = []
      taco_count.times do
        recipient_ids.each do |recipient_id|
          tacos << Taco.create(
            giver_id: author_id,
            recipient_id: recipient_id,
            original_text: text,
            channel_id: channel_id,
            message_id: message_id,
            given_at: given_at,
          )
        end
      end
      return tacos
    end

    def gives_tacos?
      recipient_ids.count > 0 && taco_count > 0
    end

    private

    def recipient_ids
      @recipient_ids ||= text.scan(/<@(.*?)>/).flatten
    end

    def taco_count
      @taco_count ||= text.scan(/:taco:/).flatten.count
    end
  end
end
