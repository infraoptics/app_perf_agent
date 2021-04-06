# frozen_string_literal: true

require 'vmstat'
require_relative '../base'

module AppPerfAgent
  module Plugin
    module System
      # Load class to collect load stats from the host
      class Load < AppPerfAgent::Plugin::Base
        # https://github.com/threez/ruby-vmstat/blob/master/lib/vmstat/load_average.rb#L6-L8
        def call
          loads = Vmstat.load_average
          [
            ['system.load.one_minute',     loads.one_minute],
            ['system.load.five_minute',    loads.five_minutes],
            ['system.load.fifteen_minute', loads.fifteen_minutes]
          ]
        end
      end
    end
  end
end

AppPerfAgent.logger.info 'Loading Load monitoring.'
