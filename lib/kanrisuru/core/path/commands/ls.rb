# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      def ls(opts = {})
        path = opts[:path]
        all  = opts[:all]
        id   = opts[:id]

        command = Kanrisuru::Command.new('ls')
        command.append_flag('-i')
        command.append_flag('-l')
        command.append_flag('-a', all)
        command.append_flag('-n', id)

        command << (path || pwd.path)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Ls.parse(cmd, id)
        end
      end
    end
  end
end
