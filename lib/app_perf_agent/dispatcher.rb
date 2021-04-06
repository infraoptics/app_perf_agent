# frozen_string_literal: true

require 'net/http'
require 'msgpack'
require 'base64'

module AppPerfAgent
  # rubocop:disable Style/Documentation
  class Dispatcher
    # rubocop:enable Style/Documentation
    def initialize
      @start_time = Time.now
      @queue = Queue.new
    end

    def add_event(event)
      @queue << event
    end

    def queue_empty?
      @queue.size.to_i.zero?
    end

    def dispatch_interval
      30
    end

    def ready?
      Time.now > @start_time + dispatch_interval.to_f && !queue_empty?
    end

    def reset
      @queue.clear
      @start_time = Time.now
    end

    def dispatch
      events = drain(@queue)
      dispatch_events(events.dup)
    rescue StandardError => e
      ::AppPerfAgent.logger.error e.inspect.to_s
      ::AppPerfAgent.logger.error e.backtrace.inspect.to_s
    ensure
      reset
    end

    private

    def dispatch_events(data)
      # rubocop:disable Style/GuardClause
      if data&.length&.positive?
        uri = URI(url)

        sock = Net::HTTP.new(uri.host, uri.port)
        sock.use_ssl = AppPerfAgent.options[:ssl]
        # rubocop:disable Layout/LineLength
        req = Net::HTTP::Post.new(uri.path,
                                  { 'Content-Type' => 'application/json', 'Accept-Encoding' => 'gzip',
                                    'User-Agent' => 'gzip' })
        req.body = compress_body(data)
        # rubocop:enable Layout/LineLength
        req.content_type = 'application/octet-stream'

        sock.start do |http|
          http.read_timeout = 30
          http.request(req)
        end
        data.clear
      end
      # rubocop:enable Style/GuardClause
    end

    def compress_body(data)
      body = MessagePack.pack({
                                'host' => AppPerfAgent.hostname,
                                'data' => data
                              })

      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      Base64.encode64(compressed_body)
    end

    def drain(queue)
      Array.new(queue.size) { queue.pop }
    end

    def url
      @url ||= "http://#{AppPerfAgent.options[:host]}/api/listener/3/#{AppPerfAgent.options[:license_key]}"
    end
  end
end
