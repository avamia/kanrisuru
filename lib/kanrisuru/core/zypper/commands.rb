# frozen_string_literal: true

require_relative 'commands/add_lock'
require_relative 'commands/add_repo'
require_relative 'commands/add_service'
require_relative 'commands/clean_cache'
require_relative 'commands/clean_locks'
require_relative 'commands/dist_upgrade'
require_relative 'commands/info'
require_relative 'commands/install'
require_relative 'commands/install_new_recommends'
require_relative 'commands/list_locks'
require_relative 'commands/list_patches'
require_relative 'commands/list_repos'
require_relative 'commands/list_services'
require_relative 'commands/list_updates'
require_relative 'commands/modify_repo'
require_relative 'commands/modify_service'
require_relative 'commands/patch'
require_relative 'commands/patch_check'
require_relative 'commands/purge_kernels'
require_relative 'commands/refresh_repos'
require_relative 'commands/refresh_services'
require_relative 'commands/remove'
require_relative 'commands/remove_lock'
require_relative 'commands/remove_repo'
require_relative 'commands/remove_service'
require_relative 'commands/rename_repo'
require_relative 'commands/search'
require_relative 'commands/source_install'
require_relative 'commands/update'
require_relative 'commands/verify'

module Kanrisuru
  module Core
    module Zypper
      private

      def zypper_global_opts(command, opts)
        command.append_flag('--non-interactive')
        command.append_flag('--ignore-unknown')
        command.append_flag('--no-color')
        command.append_flag('--no-abbrev')
        command.append_arg('--config', opts[:config_file])
      end

      def zypper_solver_opts(command, opts)
        command.append_flag('--debug-solver', opts[:debug_solver])
        command.append_flag('--force-resolution', opts[:force_resolution])
        command.append_flag('--no-force-resolution', opts[:no_force_resolution])

        solver_focus_mode = opts[:solver_focus_mode]
        if Kanrisuru::Util.present?(solver_focus_mode) && SOLVER_FOCUS_MODES.include?(solver_focus_mode)
          command.append_arg('--solver-focus', solver_focus_mode)
        end

        command.append_flag('--clean-deps', opts[:clean_deps])
        command.append_flag('--no-clean-deps', opts[:no_clean_deps])
      end

      def zypper_download_and_install_opts(command, opts)
        command.append_flag('--download-only', opts[:download_only])
        command.append_flag('--download-in-advance', opts[:download_in_advance])
        command.append_flag('--download-in-heaps', opts[:download_in_heaps])
        command.append_flag('--download-as-needed', opts[:download_as_needed])
      end

      def zypper_expert_opts(command, opts)
        command.append_flag('--allow-downgrade', opts[:allow_downgrade])
        command.append_flag('--no-allow-downgrade', opts[:no_allow_downgrade])
        command.append_flag('--allow-name-change', opts[:allow_name_change])
        command.append_flag('--no-allow-name-change', opts[:no_allow_name_change])
        command.append_flag('--allow-arch-change', opts[:allow_arch_change])
        command.append_flag('--no-allow-arch-change', opts[:no_allow_arch_change])
        command.append_flag('--allow-vendor-change', opts[:allow_vendor_change])
        command.append_flag('--no-allow-vendor-change', opts[:no_allow_vendor_change])
      end

      def zypper_gpg_opts(command, opts)
        command.append_flag('--gpgcheck', opts[:gpgcheck])
        command.append_flag('--gpgcheck-strict', opts[:gpgcheck_strict])
        command.append_flag('--gpgcheck-allow-unsigned', opts[:gpgcheck_allow_unsigned])
        command.append_flag('--gpgcheck-allow-unsigned-repo', opts[:gpgcheck_allow_unsigned_repo])
        command.append_flag('--gpgcheck-allow-unsigned-package', opts[:gpgcheck_allow_unsigned_package])
        command.append_flag('--no-gpgcheck', opts[:no_gpgcheck])
        command.append_flag('--default-gpgcheck', opts[:default_gpgcheck])
      end

      def zypper_repos_opt(command, opts)
        zypper_array_opt(command, opts[:repos], '--repo')
      end

      def zypper_patch_category_opt(command, opts)
        zypper_array_opt(command, opts[:category], '--category', PATCH_CATEGORIES)
      end

      def zypper_patch_severity_opt(command, opts)
        zypper_array_opt(command, opts[:severity], '--severity', PATCH_SEVERITIES)
      end

      def zypper_array_opt(command, value, opt_value, array = nil)
        return unless Kanrisuru::Util.present?(value)

        values = value.instance_of?(String) ? [value] : value
        values.each do |v|
          next if Kanrisuru::Util.present?(array) && !array.include?(v)

          command.append_arg(opt_value, v)
        end
      end

      def zypper_package_type_opt(command, opts)
        type = opts[:type]
        command.append_arg('-t', type) if Kanrisuru::Util.present?(type) && PACKAGE_TYPES.include?(type)
      end
    end
  end
end
