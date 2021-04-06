# frozen_string_literal: true

module AppPerfAgent
  module Plugin
    # rubocop:disable Style/Documentation
    class Base
      # rubocop:enable Style/Documentation
      def self.descendants
        @descendants ||= ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def call
        raise 'Not Implemented'
      end
    end
  end
end
