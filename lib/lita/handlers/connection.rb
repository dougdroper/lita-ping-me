require 'typhoeus'

module Lita
  module Handlers
    class Connection
      attr_reader :urls, :redis, :log

      def initialize(urls, redis, log)
        @redis = redis
        @log = log
        @urls = Array(urls)
      end

      def current_status
        requests = queue_requests
        hydra.run
        format_requests(requests)
      end

      private

      def format_requests(requests)
        requests.each_with_object({}) do |request, hash|
          redis.append("#{request.base_url}-#{request.response.code}", "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}, #{request.response.time}" + "\n")
          hash[request.base_url] = { code: request.response.code, time: request.response.time }
        end
      end

      def queue_requests
        urls.map do |url|
          Typhoeus::Request.new(url).tap do |request|
            hydra.queue(request)
          end
        end
      end

      def hydra
        @hydra ||= Typhoeus::Hydra.new
      end
    end
  end
end
