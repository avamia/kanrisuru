# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_modify_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'modifyrepo'

        command.append_arg('--name', opts[:name])
        command.append_arg('--priority', opts[:priority])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--keep-packages', opts[:keep_packages])
        command.append_flag('--no-keep-packages', opts[:no_keep_packages])

        zypper_gpg_opts(command, opts)

        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        if Kanrisuru::Util.present?(opts[:medium_type])
          raise ArgumentError, 'Invalid medium type' unless MEDIUM_TYPES.include?(opts[:medium_type])

          command.append_arg('--medium-type', opts[:medium_type])
        end

        command.append_array(opts[:repos])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
