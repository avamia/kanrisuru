# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def last(opts = {})
        command =
          if opts[:failed_attempts]
            Kanrisuru::Command.new('lastb')
          else
            Kanrisuru::Command.new('last')
          end

        command.append_flag('-i')
        command.append_flag('-F')
        command.append_arg('-f', opts[:file])

        ## Some systems only use 1 space between user and TTY field
        ## Add an additional space in output formatting for simple parsing
        ## logic.
        command | "sed 's/ /  /'"

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Last.parse(cmd, opts)
        end
      end
    end
  end
end
