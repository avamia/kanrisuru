# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_clean(opts)
        command = Kanrisuru::Command.new('yum clean')

        command.append_flag('dbcache', opts[:dbcache])
        command.append_flag('expire-cache', opts[:expire_cache])
        command.append_flag('metadata', opts[:metadata])
        command.append_flag('packages', opts[:packages])
        command.append_flag('headers', opts[:headers])
        command.append_flag('rpmdb', opts[:rpmdb])
        command.append_flag('all', opts[:all])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
