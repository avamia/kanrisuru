# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_add_lock(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'addlock'

        command.append_arg('--repo', opts[:repo])
        zypper_package_type_opt(command, opts)

        command << opts[:lock]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
