# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_add_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'addrepo'

        command.append_flag('--check', opts[:check])
        command.append_flag('--no-check', opts[:no_check])
        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--keep-packages', opts[:keep_packages])
        command.append_flag('--no-keep-packages', opts[:no_keep_packages])
        command.append_arg('--priority', opts[:priority])

        zypper_gpg_opts(command, opts)
        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
