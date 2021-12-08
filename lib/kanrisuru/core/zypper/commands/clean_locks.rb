# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_clean_locks(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'cleanlocks'

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
