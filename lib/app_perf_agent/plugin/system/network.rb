# frozen_string_literal: true

require 'vmstat'
require_relative '../base'

module AppPerfAgent
  module Plugin
    module System
      # Network class to collect network stats from the host
      class Network < AppPerfAgent::Plugin::Base
        # https://github.com/threez/ruby-vmstat/blob/master/lib/vmstat/network_interface.rb#L2-L8
        def call
          inets = Vmstat.network_interfaces
          inets.flat_map do |inet|
            [
              ['system.network.in_bytes', inet.in_bytes, { 'name' => inet.name.to_s }],
              ['system.network.in_errors', inet.in_errors, { 'name' => inet.name.to_s }],
              ['system.network.in_drops', inet.in_drops, { 'name' => inet.name.to_s }],
              ['system.network.out_bytes', inet.out_bytes, { 'name' => inet.name.to_s }],
              ['system.network.out_errors', inet.out_errors, { 'name' => inet.name.to_s }]
            ]
          end
        end
      end
    end
  end
end

AppPerfAgent.logger.info 'Loading Network monitoring.'
