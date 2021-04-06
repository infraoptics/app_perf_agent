# frozen_string_literal: true

require 'vmstat'
require_relative '../base'

module AppPerfAgent
  module Plugin
    module System
      # CPU class to collect cpu stats from the host
      class Cpu < AppPerfAgent::Plugin::Base
        # https://github.com/threez/ruby-vmstat/blob/master/lib/vmstat/cpu.rb#L2-L12
        attr_accessor :last

        def initialize
          self.last = Vmstat.snapshot.cpus
          super
        end

        def call
          cpus = Vmstat.snapshot.cpus
          metrics = cpus.each_with_index.flat_map do |cpu, index|
            # rubocop:disable Layout/LineLength
            total = (cpu.idle + cpu.nice + cpu.system + cpu.user) - (last[index].idle + last[index].nice + last[index].system + last[index].user)
            [
              ['system.cpu.idle',   (cpu.idle - last[index].idle).to_f / total * 100.to_f,   { 'num' => cpu.num }],
              ['system.cpu.nice',   (cpu.nice - last[index].nice).to_f / total * 100.to_f,   { 'num' => cpu.num }],
              ['system.cpu.system', (cpu.system - last[index].system).to_f / total * 100.to_f,
               { 'num' => cpu.num }],
              ['system.cpu.user',   (cpu.user - last[index].user).to_f / total * 100.to_f, { 'num' => cpu.num }]
            ]
          end
          # rubocop:enable Layout/LineLength
          self.last = cpus
          metrics
        end
      end
    end
  end
end

AppPerfAgent.logger.info 'Loading CPU monitoring.'
