# frozen_string_literal: true

module AppPerfAgent
  # rubocop:disable Style/Documentation
  module Plugin
    # rubocop:enable Style/Documentation
    class << self
      def load_plugins
        pattern = File.join(File.dirname(__FILE__), 'plugin', '**', '*.rb')

        Dir.glob(pattern).sort.each do |f|
          require f
        rescue StandardError => e
          AppPerfAgent.logger.info "Error loading plugin '#{f}' : #{e}"
          AppPerfAgent.logger.info e.backtrace.first.to_s
        end
      end

      def plugins
        @plugins ||= ::AppPerfAgent::Plugin::Base
                     .descendants
                     .map(&:new)
      end
    end
  end
end
