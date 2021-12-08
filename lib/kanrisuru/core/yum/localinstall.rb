module Kanrisuru
  module Core
    module Yum
      def yum_localinstall(opts)
        command = Kanrisuru::Command.new('yum localinstall')
        yum_disable_repo(command, opts[:disable_repo])
        command.append_flag('-y')

        if Kanrisuru::Util.present?(opts[:repos])
          repos = Kanrisuru::Util.array_join_string(opts[:repos], ' ')
          command << repos
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
