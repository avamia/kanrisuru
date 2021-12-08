# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      def echo(text, opts = {})
        command = Kanrisuru::Command.new('echo')
        command.append_flag('-e', opts[:backslash])
        command << "'#{text}'"

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Echo.parse(cmd, opts)
        end
      end
    end
  end
end
