# frozen_string_literal: true

require 'date'

require_relative 'yum/types'
require_relative 'yum/parser'
require_relative 'yum/commands'

module Kanrisuru
  module Core
    module Yum
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
    end
  end
end
