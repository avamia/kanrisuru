# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_info(opts)
        command = Kanrisuru::Command.new('yum info')
        command.append_flag('--quiet')
        command.append_flag('installed', opts[:installed])

        command << Kanrisuru::Util.array_join_string(opts[:packages], ' ') if opts[:packages]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Info.parse(cmd)
        end
      end
    end
  end
end
