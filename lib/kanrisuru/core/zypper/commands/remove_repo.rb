# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_remove_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'removerepo'

        command.append_flag('--loose-auth', opts[:loose_auth])
        command.append_flag('--loose-query', opts[:loose_query])
        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        if Kanrisuru::Util.present?(opts[:media_type])
          raise ArgumentError, 'Invalid media type' unless ZYPPER_MEDIA_TYPES.include?(opts[:media_type])

          command.append_arg('--media-type', opts[:media_type])
        end

        command.append_array(opts[:repos])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
