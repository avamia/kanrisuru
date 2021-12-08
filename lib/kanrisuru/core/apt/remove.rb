module Kanrisuru
  module Core
    module Apt
      def apt_remove(opts)
        command = Kanrisuru::Command.new('apt-get remove')
        command.append_flag('-y')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
