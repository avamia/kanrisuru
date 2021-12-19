# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_remove_service(opts)
        service = opts[:service]

        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'removeservice'
        command.append_flag('--loose-auth', opts[:loose_auth])
        command.append_flag('--loose-query', opts[:loose_query])

        service = "'#{service}'" if service.match(/\s/)

        command << service

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
