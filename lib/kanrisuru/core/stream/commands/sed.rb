# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      def sed(path, expression, replacement, opts = {})
        command = Kanrisuru::Command.new('sed')
        command.append_flag('-i', opts[:in_place])
        command.append_flag('-r', opts[:regexp_extended])

        command << "'s/#{expression}/#{replacement}/g'"
        command << "'#{path}'"

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Sed.parse(cmd, opts)
        end
      end
    end
  end
end
