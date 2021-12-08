# frozen_string_literal: true

require 'date'

require_relative 'zypper/constants'
require_relative 'zypper/common'
require_relative 'zypper/parsers'

require_relative 'zypper/add_lock'
require_relative 'zypper/add_repo'
require_relative 'zypper/add_service'
require_relative 'zypper/clean_cache'
require_relative 'zypper/clean_locks'
require_relative 'zypper/dist_upgrade'
require_relative 'zypper/info'
require_relative 'zypper/install'
require_relative 'zypper/install_new_recommends'
require_relative 'zypper/list_locks'
require_relative 'zypper/list_patches'
require_relative 'zypper/list_repos'
require_relative 'zypper/list_services'
require_relative 'zypper/list_updates'
require_relative 'zypper/modify_repo'
require_relative 'zypper/modify_service'
require_relative 'zypper/patch'
require_relative 'zypper/patch_check'
require_relative 'zypper/purge_kernels'
require_relative 'zypper/refresh_repos'
require_relative 'zypper/refresh_services'
require_relative 'zypper/remove'
require_relative 'zypper/remove_lock'
require_relative 'zypper/remove_repo'
require_relative 'zypper/remove_service'
require_relative 'zypper/rename_repo'
require_relative 'zypper/search'
require_relative 'zypper/source_install'
require_relative 'zypper/update'
require_relative 'zypper/verify'

module Kanrisuru
  module Core
    module Zypper
      include Constants
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
