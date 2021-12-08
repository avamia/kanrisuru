# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def uptime
        ## Ported from https://github.com/djberg96/sys-uptime
        command = Kanrisuru::Command.new('cat /proc/uptime')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Uptime.parse(cmd)
        end
      end
    end
  end
end
