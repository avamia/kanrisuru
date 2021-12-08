# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_source_install(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'sourceinstall'

        zypper_repos_opt(command, opts)
        command.append_flag('--build-deps-only', opts[:build_deps_only])
        command.append_flag('--no-build-deps', opts[:no_build_deps])
        command.append_flag('--download-only', opts[:download_only])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
