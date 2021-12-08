# frozen_string_literal: true

require 'date'

require_relative 'yum/constants'
require_relative 'yum/parsers'

require_relative 'yum/autoremove'
require_relative 'yum/clean'
require_relative 'yum/erase'
require_relative 'yum/info'
require_relative 'yum/install'
require_relative 'yum/list'
require_relative 'yum/localinstall'
require_relative 'yum/remove'
require_relative 'yum/repolist'
require_relative 'yum/search'
require_relative 'yum/update'
require_relative 'yum/upgrade'

module Kanrisuru
  module Core
    module Yum
      include Constants
      extend OsPackage::Define

      os_define :fedora, :yum

      def yum(action, opts = {})
        case action
        when 'install'
          yum_install(opts)
        when 'localinstall'
          yum_localinstall(opts)
        when 'list'
          yum_list(opts)
        when 'search'
          yum_search(opts)
        when 'info'
          yum_info(opts)
        when 'repolist'
          yum_repolist(opts)
        when 'clean'
          yum_clean(opts)
        when 'remove'
          yum_remove(opts)
        when 'autoremove'
          yum_autoremove(opts)
        when 'erase'
          yum_erase(opts)
        when 'update'
          yum_update(opts)
        when 'upgrade'
          yum_upgrade(opts)
        end
      end

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
