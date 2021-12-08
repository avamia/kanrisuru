# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_dist_upgrade(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'dist-upgrade'

        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])
        command.append_flag('--dry-run', opts[:dry_run])

        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
