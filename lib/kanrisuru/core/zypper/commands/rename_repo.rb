# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_rename_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'renamerepo'
        command << opts[:repo]
        command << opts[:alias]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
