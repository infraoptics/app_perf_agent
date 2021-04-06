# frozen_string_literal: true

require 'logger'

module AppPerfAgent
  # rubocop:disable Style/Documentation
  class Logger
    # rubocop:enable Style/Documentation
    def self.initialize_logger(log_target = $stdout)
      @logger = ::Logger.new(log_target)
      @logger.level = ::Logger::INFO
      @logger
    end

    def self.logger
      defined?(@logger) ? @logger : initialize_logger
    end

    def self.logger=(log)
      @logger = (log || ::Logger.new(File::NULL))
    end

    def logger
      AppPerfAgent::Logger.logger
    end
  end
end
