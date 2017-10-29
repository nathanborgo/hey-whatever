# HeyWhatever

Bringing simplicity back to office recognition since 2017.

## Set up
Throw a .env into the root of the repo like so:

```
POSTGRES_USERNAME=
POSTGRES_PASSWORD=

SLACK_CLIENT_ID=
SLACK_CLIENT_SECRET=
SLACK_VERIFICATION_TOKEN=
SLACK_BOT_ACCESS_TOKEN=
```

`bundle` up.

Run `rake db:create` to create dev and test databases.

Run `rake db:migrate` to get the dev database up to speed. You should probably run `RACK_ENV=test rake db:migrate` while you're at it.

Run `rackup config.ru` to start the Sinatra server.

## Example requests
These are mock requests, just like what Slack's Event API sends us. The only difference is that I swapped out the "token" for security purposes.

You can add a `verbose_request` URL parameter to print the request in your logs. I used this to get the exact requests Slack was making to us.

### URL Verification
Slack requires you to respond to a "challenge" when first setting up a URL for a Slack app.
```
curl -X "POST" "http://localhost:9292/slack_api/v1/events?verbose_request=true" \
     -H "Cookie: __profilin=p%3Dt" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d $'{
  "token": "xxx",
  "challenge": "yyTY5cemXZrxEVPsWIBlgkMnKcoYpbSMEkZdwJ45dP9GR5QXDiXc",
  "type": "url_verification"
}'
```

### Message
This is what the request will look like whenever someone sends a message in a public channel.
```
curl -X "POST" "http://localhost:9292/slack_api/v1/events?verbose_request=true" \
     -H "Cookie: __profilin=p%3Dt" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d $'{
  "event_time": "1509223537",
  "api_app_id": "A7RS13PLP",
  "event": {
    "text": "<@U3LADN8LA> testing self :taco: message",
    "ts": "1509223537.000008",
    "channel": "C7RCLE8LT",
    "type": "message",
    "event_ts": "1509223537.000008",
    "user": "U3LADN8LA"
  },
  "authed_users": [
    "U3LADN8LA"
  ],
  "team_id": "T3KKUHYNM",
  "event_id": "Ev7SCD1VK8",
  "token": "xxx",
  "type": "event_callback"
}'
```

## Running tests

Make sure you ran `rake db:create` and `RACK_ENV=test rake db:migrate`.

Run `rake test`.
