# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_add_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'addservice'

        name = ("'#{opts[:name]}'" if Kanrisuru::Util.present?(opts[:name]))

        command.append_arg('--name', name)
        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])

        command << opts[:service]
        command << opts[:alias]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
