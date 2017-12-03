module SlackRequestHelper
  def message_event(text:)
    {
      token: "mock_token",
      team_id: "T3KKUHYNM",
      api_app_id: "A7RS13PLP",
      type: "event_callback",
      event_id: "Ev7SCD1VK8",
      event_time: "1509223537",
      authed_users: ["U7RD3CCF6"], # Molly's account.
      event: {
        type: "message",
        user: "U7RD3CCF6", # Molly's account.
        text: text,
        ts: "1509223537.000008",
        channel: "C7RCLE8LT",
        event_ts: "1509223537.000008"
      }
    }.to_json
  end
end

