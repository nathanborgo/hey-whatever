module Slack
  class Message
    attr_reader :author_id, :text, :channel_id

    def initialize(request)
      @author_id = request.dig("event", "user")
      @text = request.dig("event", "text")
      @channel_id = request.dig("event", "channel")
    end

    def assign_tacos
      recipient_ids.each do |recipient_id|
        Taco.create(
         giver_id: author_id,
         recipient_id: recipient_id,
         original_text: text,
         channel_id: channel_id,
        )
      end
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
