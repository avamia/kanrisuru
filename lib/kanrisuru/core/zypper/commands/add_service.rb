
module Kanrisuru
  module Core
    module Zypper
      def zypper_add_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'addservice'

        command.append_arg('--name', opts[:name])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])

        command.append_array(opts[:services])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
