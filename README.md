# lita-ping-me

**lita-ping-me** is a (slack) handler for [Lita](https://www.lita.io/) to ping a web service periodically and post to a channel if there is an error

## Installation

Add **lita-ping-me** to your Lita instance's Gemfile:

``` ruby
gem "lita-ping-me"
```

## Configuration

### Required attributes

* `urls` (Array) – An array of urls for lita-ping-me to periodically check
* `frequency` (Integer) – How frequent to check for the service in minutes
* `channel` (String) – Which (slack) channel id to post alerts to.

To get the channel ID:

```
 channel find channel-name
```

### Example

``` ruby
Lita.configure do |config|
  config.handlers.ping_me.urls = ["http://google.com", "https://github.com"]
  config.handlers.ping_me.room = 'C03EV32P*'
  config.handlers.ping_me.frequency = 1
end
```

### Usage

* `lita status http://google.com` -> returns status of url
* `lita times http://google.com 200` -> returns last 10 times of url
* `lita any errors?` -> checks currently set urls for any 500's
* `lita sleep` -> stop checking for errors for 20 minutes
* `lita sleep 30` -> stop checking for errors for 30 minutes


## License

[MIT](http://opensource.org/licenses/MIT)
