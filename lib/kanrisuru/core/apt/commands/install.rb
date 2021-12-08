# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_install(opts)
        command = Kanrisuru::Command.new('apt-get install')
        command.append_flag('-y')

        command.append_flag('--no-upgrade', opts[:no_upgrade])
        command.append_flag('--only-upgrade', opts[:only_upgrade])
        command.append_flag('--reinstall', opts[:reinstall])

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
