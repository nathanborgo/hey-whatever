module Slack
  class UrlVerification
    attr_reader :challenge

    def initialize(request)
      @challenge = request["challenge"]
    end
  end
end
