require_relative 'commands/autoremove'
require_relative 'commands/clean'
require_relative 'commands/erase'
require_relative 'commands/info'
require_relative 'commands/install'
require_relative 'commands/list'
require_relative 'commands/localinstall'
require_relative 'commands/remove'
require_relative 'commands/repolist'
require_relative 'commands/search'
require_relative 'commands/update'
require_relative 'commands/upgrade'

module Kanrisuru
  module Core
    module Yum
      private
      
      ## Bug reported on the output of the yum command
      ## https://bugzilla.redhat.com/show_bug.cgi?id=584525
      ## that autowraps text when used in a script beyond 80 chars wide.
      ## Work-around with formatting by
      ## piping through trimming extra newline chars.
      def pipe_output_newline(command)
        command | "tr '\\n' '#'"
        command | "sed -e 's/# / /g'"
        command | "tr '#' '\\n'"
      end

      def yum_disable_repo(command, repo)
        return unless Kanrisuru::Util.present?(repo)
        command.append_flag("--disablerepo=#{repo}")
      end
    end
  end
end
