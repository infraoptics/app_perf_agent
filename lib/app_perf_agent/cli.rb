# frozen_string_literal: true

$stdout.sync = true

require 'singleton'
require 'optparse'

require_relative '../app_perf_agent'

module AppPerfAgent
  # rubocop:disable Style/Documentation
  class CLI
    # rubocop:enable Style/Documentation
    include Singleton unless $TESTING

    def initialize; end

    def parse(args = ARGV)
      setup_options(args)
      daemonize
      write_pid
    end

    def run
      worker = AppPerfAgent::Worker.new
      worker.load_plugins

      begin
        AppPerfAgent.logger.info 'Starting AppPerfAgent.'
        worker.start
        # rubocop:disable Lint/AssignmentInCondition

        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        AppPerfAgent.logger.info 'Shutting down AppPerfAgent.'
        worker.stop
        exit(0)
        # rubocop:enable Lint/AssignmentInCondition
      end
    end

    def handle_signal(sig)
      case sig
      when 'INT'
        raise Interrupt
      when 'TERM'
        raise Interrupt
      end
    end

    def options
      AppPerfAgent.options
    end

    private

    def daemonize
      return unless options[:daemon]

      ::Process.daemon(true, true)
    end

    def setup_options(args)
      opts = parse_options(args)
      options.merge!(opts)
    end

    def parse_options(argv)
      opts = { daemon: false }

      parser = OptionParser.new do |o|
        o.banner = 'app_perf_agent [options]'

        o.on '-b', '--background', 'Daemonize process' do |_arg|
          opts[:daemon] = true
        end

        o.on '-l', '--license-key LICENSE_KEY', 'License Key' do |arg|
          opts[:license_key] = arg
        end

        o.on '--host HOST', 'App Perf Host' do |arg|
          opts[:host] = arg
        end

        o.on '--ssl', 'Enable SSL To App Perf' do |_arg|
          opts[:ssl] = true
        end

        o.on '-v', '--verbose', 'Enable verbose logging' do |_arg|
          AppPerfAgent.logger.level = ::Logger::DEBUG
        end

        o.on_tail '-h', '--help', 'Show help' do
          puts o
          exit
        end
      end

      parser.parse!(argv)

      if opts[:license_key].to_s.length.zero?
        AppPerfAgent.logger.info 'No license key specified. Exiting.'
        exit 1
      end

      AppPerfAgent.logger.info "Initializing with options: #{opts}"

      opts
    end

    def write_pid
      # rubocop:disable Style/GuardClause
      # rubocop:disable Lint/AssignmentInCondition
      if path = options[:pidfile]
        pidfile = File.expand_path(path)
        File.open(pidfile, 'w') do |f|
          f.puts ::Process.pid
        end
      end
      # rubocop:enable Style/GuardClause
      # rubocop:enable Lint/AssignmentInCondition
    end
  end
end
