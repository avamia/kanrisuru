# frozen_string_literal: true

module Kanrisuru
  module Core
    module Mount
      def umount(opts = {})
        all = opts[:all]
        type = opts[:type]
        command = Kanrisuru::Command.new('umount')

        command.append_flag('--fake', opts[:fake])
        command.append_flag('--no-canonicalize', opts[:no_canonicalize])
        command.append_flag('-n', opts[:no_mtab])
        command.append_flag('-r', opts[:fail_remount_readonly])
        command.append_flag('-d', opts[:free_loopback])

        command.append_flag('-l', opts[:lazy])
        command.append_flag('-f', opts[:force])

        if Kanrisuru::Util.present?(all)
          command.append_flag('-a')
          add_type(command, type)
          add_test_opts(command, opts[:test_opts], type)
        else
          command << opts[:device] if Kanrisuru::Util.present?(opts[:device])
          command << opts[:directory] if Kanrisuru::Util.present?(opts[:directory])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
