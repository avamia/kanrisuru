# frozen_string_literal: true

require_relative 'commands/cpu_info'
require_relative 'commands/free'
require_relative 'commands/kernel_statistics'
require_relative 'commands/kill'
require_relative 'commands/last'
require_relative 'commands/load_average'
require_relative 'commands/load_env'
require_relative 'commands/lscpu'
require_relative 'commands/lsof'
require_relative 'commands/poweroff'
require_relative 'commands/ps'
require_relative 'commands/reboot'
require_relative 'commands/uptime'
require_relative 'commands/w'

module Kanrisuru
  module Core
    module System
      private

      def format_shutdown_time(time)
        if time.instance_of?(Integer) || !/^[0-9]+$/.match(time).nil?
          "+#{time}"
        elsif !/^[0-9]{0,2}:[0-9]{0,2}$/.match(time).nil? || time == 'now'
          time
        else
          raise ArgumentError, 'Invalid time format'
        end
      end
    end
  end
end
