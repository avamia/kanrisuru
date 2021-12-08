# frozen_string_literal: true

require_relative 'apt/types'
require_relative 'apt/parser'
require_relative 'apt/commands'

module Kanrisuru
  module Core
    module Apt
      extend OsPackage::Define

      os_define :debian, :apt

      def apt(action, opts = {})
        case action
        when 'list'
          apt_list(opts)
        when 'update'
          apt_update(opts)
        when 'upgrade'
          apt_upgrade(opts)
        when 'full-upgrade', 'full_upgrade'
          apt_full_upgrade(opts)
        when 'install'
          apt_install(opts)
        when 'remove'
          apt_remove(opts)
        when 'purge'
          apt_purge(opts)
        when 'autoremove'
          apt_autoremove(opts)
        when 'search'
          apt_search(opts)
        when 'show'
          apt_show(opts)
        when 'clean'
          apt_clean(opts)
        when 'autoclean'
          apt_autoclean(opts)
        end
      end
    end
  end
end
