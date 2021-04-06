# frozen_string_literal: true

require 'vmstat'
require_relative '../base'

module AppPerfAgent
  module Plugin
    module System
      # Memory class to collect memory stats from the host
      class Memory < AppPerfAgent::Plugin::Base
        # https://github.com/threez/ruby-vmstat/blob/master/lib/vmstat/memory.rb#L2-L16
        # https://github.com/threez/ruby-vmstat/blob/master/lib/vmstat/linux_memory.rb#L7-L8
        def call
          memory = Vmstat.memory
          [
            ['system.memory.free_bytes',       memory.free_bytes],
            ['system.memory.inactive_bytes',   memory.inactive_bytes],
            ['system.memory.active_bytes',     memory.active_bytes],
            ['system.memory.wired_bytes',      memory.wired_bytes],
            ['system.memory.total_bytes',      memory.total_bytes],
            ['system.memory.available_bytes',  memory.available_bytes],
            ['system.memory.pagesize',         memory.pagesize],
            ['system.memory.pageins',          memory.pageins],
            ['system.memory.pageouts',         memory.pageouts]
          ]
        end
      end
    end
  end
end

AppPerfAgent.logger.info 'Loading Memory monitoring.'
