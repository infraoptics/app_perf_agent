# frozen_string_literal: true

module AppPerfAgent
  # Worker class to collect metrics from the enabled plugins in the plugin folder
  class Worker
    def initialize
      @running = false
    end

    def load_plugins
      AppPerfAgent::Plugin.load_plugins
    end

    def dispatcher
      @dispatcher ||= AppPerfAgent::Dispatcher.new
    end

    def stop
      @running = false
    end

    def start
      @running = true

      while @running
        collect if dispatcher.queue_empty?

        if dispatcher.ready?
          dispatcher.dispatch
          dispatcher.reset
        end

        sleep 1
      end
    end

    def collect
      AppPerfAgent::Plugin.plugins.each do |plugin|
        items = plugin.call
        items.map { |i| AppPerfAgent.logger.debug i }
        Array(items).each do |item|
          key, value, tags = item
          metric = ['metric', Time.now.to_f, key, value, tags || {}]
          dispatcher.add_event(metric)
        end
      end
    end
  end
end
