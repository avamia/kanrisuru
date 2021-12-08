# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      module Parser
        class Uptime
          def self.parse(command)
            seconds = command.to_s.split[0].to_i
            minutes = seconds / 60
            hours = seconds / 3600
            days = seconds / 86_400

            seconds_dur = seconds
            days_dur = seconds_dur / 86_400
            seconds_dur -= days_dur * 86_400
            hours_dur = seconds_dur / 3600
            seconds_dur -= hours_dur * 3600
            minutes_dur = seconds_dur / 60
            seconds_dur -= minutes_dur * 60
            uptime_s = "#{days_dur}:#{hours_dur}:#{minutes_dur}:#{seconds_dur}"

            boot_time = Time.now - seconds

            Kanrisuru::Core::System::Uptime.new(
              boot_time,
              uptime_s,
              seconds,
              minutes,
              hours,
              days
            )
          end
        end
      end
    end
  end
end
