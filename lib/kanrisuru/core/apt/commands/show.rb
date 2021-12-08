# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_show(opts)
        command = Kanrisuru::Command.new('apt show')
        command.append_flag('-a')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Show.parse(cmd)
        end
      end
    end
  end
end
