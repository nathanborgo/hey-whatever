module Slack
  class Payload
    attr_reader :event

    def initialize(request)
      parsed_request = JSON.parse(request)

      @event = case event_type(parsed_request)
      when :url_verification
        Slack::UrlVerification.new(parsed_request)
      when :message
        Slack::Message.new(parsed_request)
      else
        nil
      end
    end

    private

    def event_type(request)
      if request.dig("type") == "url_verification"
        return :url_verification
      elsif request.dig("event", "type") == "message"
        return :message
      end
    end
  end
end
