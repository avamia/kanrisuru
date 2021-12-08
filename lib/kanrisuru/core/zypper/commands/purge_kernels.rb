# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_purge_kernels(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'purge-kernels'
        command.append_flag('--dry-run', opts[:dry_run])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
