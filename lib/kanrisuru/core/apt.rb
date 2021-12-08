# frozen_string_literal: true

require_relative 'apt/constants'
require_relative 'apt/parsers'

require_relative 'apt/autoclean'
require_relative 'apt/autoremove'
require_relative 'apt/clean'
require_relative 'apt/full_upgrade'
require_relative 'apt/install'
require_relative 'apt/list'
require_relative 'apt/purge'
require_relative 'apt/remove'
require_relative 'apt/search'
require_relative 'apt/show'
require_relative 'apt/update'
require_relative 'apt/upgrade'

module Kanrisuru
  module Core
    module Apt
      include Constants
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
