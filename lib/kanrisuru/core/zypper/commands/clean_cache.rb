# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_clean_cache(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'clean'
        command.append_flag('--metadata', opts[:metadata])
        command.append_flag('--raw-metadata', opts[:raw_metadata])
        command.append_flag('--all', opts[:all])
        command.append_array(opts[:repos])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
