require 'json'
require 'time'
require_relative 'connection'

module Lita
  module Handlers
    class PingMe < Handler
      SLEEP_TIME = 20
      FIVE_MINUTES = 5
      TWELVE_HOURS = 720

      config :urls
      config :room
      config :frequency

      http.get "/notify/:id", :notify

      route(/^channel find (.+)/) do |response|
        response.reply(channels(response.args.last).fetch('id', 'not found'))
      end

      route(/^status[\s+]?(.+)?/) do |response|
        urls = response.args.empty? ? config.urls : response.args
        response.reply(format(current_status(clean_urls(urls))))
      end

      route(/^times[\s+]?(.+)?/) do |response|
        url, code = response.args.first(2)
        response.reply(format_times(redis.get("#{url}-#{code}")))
      end

      route(/^sleep[\s+]?(\d+)?/, :sleep)
      route(/^wake?/, :wake)

      route(/^any errors\?/, :check_for_errors)

      on(:status) do |_|
        check_for_errors(_)
      end

      on(:current_status) do |payload|
        send_message(format(current_status))
      end

      on(:loaded) do
        start_pinging

        every(minutes_to_seconds(TWELVE_HOURS)) do |timer|
          robot.trigger(:current_status)
        end
      end

      def sleep(response)
        redis.set("sleep", true)
        time = parse_time(response.args.first.to_i)
        timer.stop
        after(time) do
          redis.set("sleep", false)
          start_pinging
        end
        response.reply("Sure, will sleep for #{seconds_to_minutes(time)} minutes")
      end

      def check_for_errors(_)
        errors.each do |url, status|
          send_message("#{url} is down: #{status.inspect}")
        end
      end

      def notify(request, response)
        return if redis.get("sleep") == 'true'
        id = request.env["router.params"][:id]
        msg = id.split('_').join(" ")
        send_message("#{msg}")
        response.body << "#{msg}"
      end

      def wake(_)
        redis.set("sleep", false)
      end

      private

      def errors
        state = current_status
        log.info(state)
        state.select { |url, status| status[:code] >= 500 }
      end

      def parse_time(minutes)
        minutes == 0 ? minutes_to_seconds(SLEEP_TIME) : minutes_to_seconds(minutes)
      end

      def seconds_to_minutes(seconds)
        seconds / 60
      end

      def minutes_to_seconds(minutes)
        minutes * 60
      end

      def start_pinging
        every(frequency) do |timer|
          robot.trigger(:status)
        end
      end

      def current_status(urls = config.urls)
        Connection.new(urls, redis, log).current_status
      end

      def target(payload = {})
        @target ||= Source.new(room: config.room || '')
      end

      def send_message(msg)
        robot.send_message(target, msg)
      end

      def frequency
        minutes_to_seconds(config.frequency || FIVE_MINUTES)
      end

      def timer
        ObjectSpace.each_object(Lita::Timer).to_a.find do |t|
          t.instance_variable_get("@interval") == frequency
        end
      end

      def format(status)
        status.map do |url, status|
          "#{url}: code #{status[:code]}, time: #{status[:time]}"
        end.join("\n")
      end

      def clean_urls(urls)
        return unless urls
        urls.map do |url|
          if url.match(/|/)
            url = url.split('|').first.gsub("<", '').gsub(">", '')
          end
          url
        end
      end

      def format_times(times)
        times.split("\n").last(10)
      end

      def channels(channel_name)
        channels = JSON.parse(http.get("https://slack.com/api/channels.list?token=#{Lita.config.adapters.slack.token}").body)
        channels['channels'].find {|c| c["name"] == channel_name } || {}
      end
    end

    Lita.register_handler(PingMe)
  end
end
