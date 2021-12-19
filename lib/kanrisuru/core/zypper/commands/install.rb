# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_install(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'install'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_arg('-n', opts[:name])
        command.append_flag('-f', opts[:force])
        command.append_flag('--oldpackage', opts[:oldpackage])
        command.append_arg('--from', opts[:from])
        command.append_arg('--capability', opts[:capability])
        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])
        command.append_flag('--replacefiles', opts[:replacefiles])

        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--allow-unsigned-rpm', opts[:allow_unsigned_rpm])

        zypper_solver_opts(command, opts)
        zypper_download_and_install_opts(command, opts)
        zypper_expert_opts(command, opts)

        command.append_array(opts[:packages])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
