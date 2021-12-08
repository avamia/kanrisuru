# frozen_string_literal: true

require 'date'

require_relative 'zypper/constants'
require_relative 'zypper/types'
require_relative 'zypper/parser'
require_relative 'zypper/commands'

module Kanrisuru
  module Core
    module Zypper
      extend OsPackage::Define

      os_define :sles, :zypper

      def zypper(action, opts = {})
        case action
        when 'repos', 'lr'
          zypper_list_repos(opts)
        when 'refresh', 'ref'
          zypper_refresh_repos(opts)
        when 'modifyrepo', 'mr'
          zypper_modify_repo(opts)
        when 'addrepo', 'ar'
          zypper_add_repo(opts)
        when 'removerepo', 'rr'
          zypper_remove_repo(opts)
        when 'renamerepo', 'nr'
          zypper_rename_repo(opts)

        when 'addservice', 'as'
          zypper_add_service(opts)
        when 'removeservice', 'rs'
          zypper_remove_service(opts)
        when 'modifyservice', 'ms'
          zypper_modify_service(opts)
        when 'services', 'ls'
          zypper_list_services(opts)
        when 'refresh-services', 'refs'
          zypper_refresh_services(opts)

        when 'addlock', 'al'
          zypper_add_lock(opts)
        when 'locks', 'll'
          zypper_list_locks(opts)
        when 'removelock', 'rl'
          zypper_remove_lock(opts)
        when 'cleanlocks', 'cl'
          zypper_clean_locks(opts)

        when 'info', 'if'
          zypper_info(opts)
        when 'install', 'in'
          zypper_install(opts)
        when 'source-install', 'si'
          zypper_source_install(opts)
        when 'verify', 've'
          zypper_verify(opts)
        when 'install-new-recommends', 'inr'
          zypper_install_new_recommends(opts)
        when 'remove', 'rm'
          zypper_remove(opts)
        when 'purge-kernels'
          zypper_purge_kernels(opts)
        when 'search', 'se'
          zypper_search(opts)
        when 'clean', 'cc'
          zypper_clean_cache(opts)
        when 'list-updates', 'lu'
          zypper_list_updates(opts)
        when 'list-patches', 'lp'
          zypper_list_patches(opts)

        when 'patch-check', 'pchk'
          zypper_patch_check(opts)
        when 'patch'
          zypper_patch(opts)
        when 'dist-upgrade', 'dup'
          zypper_dist_upgrade(opts)
        when 'update', 'up'
          zypper_update(opts)
        end
      end
    end
  end
end
