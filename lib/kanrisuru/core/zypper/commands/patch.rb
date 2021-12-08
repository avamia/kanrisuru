# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_patch(opts)
        command = Kanrisuru::Command.new('zypper')
        command.append_valid_exit_code(EXIT_INF_REBOOT_NEEDED)
        command.append_valid_exit_code(EXIT_INF_RESTART_NEEDED)
        zypper_global_opts(command, opts)

        command << 'patch'

        command.append_flag('--updatestack-only', opts[:updatestack_only])
        command.append_flag('--with-update', opts[:with_update])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])
        command.append_flag('--replacefiles', opts[:replacefiles])
        command.append_flag('--dry-run', opts[:dry_run])

        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])

        command.append_arg('--bugzilla', opts[:bugzilla])
        command.append_arg('--cve', opts[:cve])
        command.append_arg('--date', opts[:date])

        zypper_patch_category_opt(command, opts)
        zypper_patch_severity_opt(command, opts)
        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
