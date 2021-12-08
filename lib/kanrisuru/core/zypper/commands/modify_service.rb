
module Kanrisuru
  module Core
    module Zypper
      def zypper_modify_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'modifyservice'
        command.append_arg('--name', opts[:name])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        command.append_arg('--ar-to-enable', opts[:ar_to_enable])
        command.append_arg('--ar-to-disable', opts[:ar_to_disable])
        command.append_arg('--rr-to-enable', opts[:rr_to_enable])
        command.append_arg('--rr-to-disable', opts[:rr_to_disable])
        command.append_arg('--cl-to-enable', opts[:cl_to_enable])
        command.append_arg('--cl-to-disable', opts[:cl_to_disable])

        if Kanrisuru::Util.present?(opts[:medium_type])
          raise ArgumentError, 'Invalid medium type' unless MEDIUM_TYPES.include?(opts[:medium_type])

          command.append_arg('--medium-type', opts[:medium_type])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
