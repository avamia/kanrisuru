# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module Zypper
      extend OsPackage::Define

      os_define :sles, :zypper

      PACKAGE_TYPES = %w[package patch pattern product srcpackage application].freeze
      PATCH_CATEGORIES = %w[security recommended optional feature document yast].freeze
      PATCH_SEVERITIES = %w[critical important moderate low unspecified].freeze
      SOLVER_FOCUS_MODES = %w[job installed update].freeze
      MEDIUM_TYPES = %w[dir file cd dvd nfs iso http https ftp cifs smb hd].freeze

      EXIT_INF_UPDATE_NEEDED = 100
      EXIT_INF_SEC_UPDATE_NEEDED = 101
      EXIT_INF_REBOOT_NEEDED = 102
      EXIT_INF_RESTART_NEEDED = 103
      EXIT_INF_CAP_NOT_FOUND = 104

      Repo = Struct.new(
        :number,
        :alias,
        :name,
        :enabled,
        :gpg_check,
        :refresh,
        :priority,
        :type,
        :uri,
        :service
      )

      Service = Struct.new(
        :number,
        :alias,
        :name,
        :enabled,
        :gpg_check,
        :refresh,
        :priority,
        :type,
        :uri
      )

      SearchResult = Struct.new(
        :repository,
        :package,
        :status,
        :type,
        :version,
        :architecture
      )

      PackageDetail = Struct.new(
        :repository,
        :package,
        :version,
        :architecture,
        :vendor,
        :support_level,
        :install_size,
        :installed,
        :status,
        :source_package,
        :summary,
        :description
      )

      PackageUpdate = Struct.new(
        :repository,
        :package,
        :current_version,
        :available_version,
        :architecture
      )

      PatchUpdate = Struct.new(
        :repository,
        :patch,
        :category,
        :severity,
        :interactive,
        :status,
        :summary
      )

      PatchCount = Struct.new(
        :category,
        :updatestack,
        :patches
      )

      Lock = Struct.new(
        :number,
        :name,
        :matches,
        :type,
        :repository
      )

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

      private

      def zypper_clean_cache(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'clean'
        command.append_flag('--metadata', opts[:metadata])
        command.append_flag('--raw-metadata', opts[:raw_metadata])
        command.append_flag('--all', opts[:all])

        command << opts[:repos]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_list_repos(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'repos'
        command.append_flag('--details')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next unless line.match(/^\d/)

            values = line.split('|')
            values = values.map(&:strip)

            rows << Repo.new(
              values[0].to_i,
              values[1],
              values[2],
              values[3] == 'Yes',
              values[4].include?('Yes'),
              values[5] == 'Yes',
              values[6].to_i,
              values[7],
              values[8],
              values.length == 10 ? values[9] : nil
            )
          end
          rows
        end
      end

      def zypper_refresh_repos(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'refresh'

        command.append_flag('--force', opts[:force])
        command.append_flag('--force-build', opts[:force_build])
        command.append_flag('--force-download', opts[:force_download])
        command.append_flag('--build-only', opts[:build_only])
        command.append_flag('--download-only', opts[:download_only])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_modify_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'modifyrepo'

        command.append_arg('--name', opts[:name])
        command.append_arg('--priority', opts[:priority])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--keep-packages', opts[:keep_packages])
        command.append_flag('--no-keep-packages', opts[:no_keep_packages])

        command.append_flag('--gpgcheck', opts[:gpgcheck])
        command.append_flag('--gpgcheck-strict', opts[:gpgcheck_strict])
        command.append_flag('--gpgcheck-allow-unsigned', opts[:gpgcheck_allow_unsigned])
        command.append_flag('--gpgcheck-allow-unsigned-repo', opts[:gpgcheck_allow_unsigned_repo])
        command.append_flag('--gpgcheck-allow-unsigned-package', opts[:gpgcheck_allow_unsigned_package])
        command.append_flag('--no-gpgcheck', opts[:no_gpgcheck])
        command.append_flag('--default-gpgcheck', opts[:default_gpgcheck])

        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        if Kanrisuru::Util.present?(opts[:medium_type])
          raise ArgumentError, 'Invalid medium type' unless MEDIUM_TYPES.include?(opts[:medium_type])

          command.append_arg('--medium-type', opts[:medium_type])
        end

        repos = opts[:repos]
        if Kanrisuru::Util.present?(repos)
          repos = repos.instance_of?(String) ? [repos] : repos
          command << repos.join(' ')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_add_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'addrepo'

        command.append_flag('--check', opts[:check])
        command.append_flag('--no-check', opts[:no_check])
        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--keep-packages', opts[:keep_packages])
        command.append_flag('--no-keep-packages', opts[:no_keep_packages])
        command.append_flag('--gpgcheck', opts[:gpgcheck])
        command.append_flag('--gpgcheck-strict', opts[:gpgcheck_strict])
        command.append_flag('--gpgcheck-allow-unsigned', opts[:gpgcheck_allow_unsigned])
        command.append_flag('--gpgcheck-allow-unsigned-repo', opts[:gpgcheck_allow_unsigned_repo])
        command.append_flag('--gpgcheck-allow-unsigned-package', opts[:gpgcheck_allow_unsigned_package])
        command.append_flag('--no-gpgcheck', opts[:no_gpgcheck])
        command.append_flag('--default-gpgcheck', opts[:default_gpgcheck])

        command.append_arg('--priority', opts[:priority])

        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_remove_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'removerepo'

        command.append_flag('--loose-auth', opts[:loose_auth])
        command.append_flag('--loose-query', opts[:loose_query])
        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        if Kanrisuru::Util.present?(opts[:media_type])
          raise ArgumentError, 'Invalid media type' unless ZYPPER_MEDIA_TYPES.include?(opts[:media_type])

          command.append_arg('--media-type', opts[:media_type])
        end

        repos = opts[:repos]
        if Kanrisuru::Util.present?(repos)
          repos = repos.instance_of?(String) ? [repos] : repos
          command << repos.join(' ')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_rename_repo(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'renamerepo'
        command << opts[:repo]
        command << opts[:alias]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_add_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'addservice'

        command.append_arg('--name', opts[:name])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])

        services = opts[:services]
        if Kanrisuru::Util.present?(services)
          services = services.instance_of?(Array) ? services : [services]
          command << services.join(' ')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_remove_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'removeservice'
        command.append_flag('--loose-auth', opts[:loose_auth])
        command.append_flag('--loose-query', opts[:loose_query])

        services = opts[:services]
        if Kanrisuru::Util.present?(services)
          services = services.instance_of?(String) ? [services] : services
          command << services.join(' ')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_modify_service(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'modifyservice'
        command.append_arg('--name', opts[:name])

        command.append_flag('--enable', opts[:enable])
        command.append_flag('--disable', opts[:disable])
        command.append_flag('--refresh', opts[:refresh])
        command.append_flag('--no-refresh', opts[:no_refresh])
        command.append_flag('--all', opts[:all])
        command.append_flag('--local', opts[:local])
        command.append_flag('--remote', opts[:remote])

        command.append_arg('--ar-to-enable', opts[:ar_to_enable])
        command.append_arg('--ar-to-disable', opts[:ar_to_disable])
        command.append_arg('--rr-to-enable', opts[:rr_to_enable])
        command.append_arg('--rr-to-disable', opts[:rr_to_disable])
        command.append_arg('--cl-to-enable', opts[:cl_to_enable])
        command.append_arg('--cl-to-disable', opts[:cl_to_disable])

        if Kanrisuru::Util.present?(opts[:medium_type])
          raise ArgumentError, 'Invalid medium type' unless MEDIUM_TYPES.include?(opts[:medium_type])

          command.append_arg('--medium-type', opts[:medium_type])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_list_services(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'services'
        command.append_flag('--details')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next unless line.match(/^\d/)

            values = line.split('|')
            values = values.map(&:strip)

            rows << Service.new(
              values[0].to_i,
              values[1],
              values[2],
              values[3] == 'Yes',
              values[4].include?('Yes'),
              values[5] == 'Yes',
              values[6].to_i,
              values[7],
              values[8]
            )
          end
          rows
        end
      end

      def zypper_refresh_services(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'refresh-services'
        command.append_flag('--force', opts[:force])
        command.append_flag('--with-repos', opts[:with_repos])
        command.append_flag('--restore-status', opts[:restore_status])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_add_lock(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'addlock'

        command.append_arg('--repo', opts[:repo])
        zypper_package_type_opt(command, opts)

        command << opts[:lock]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_remove_lock(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'removelock'

        command.append_arg('--repo', opts[:repo])
        zypper_package_type_opt(command, opts)

        command << opts[:lock]

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_list_locks(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'locks'

        command.append_flag('--matches')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next if line == ''

            values = line.split(' | ')
            next if values.length != 5
            next if values[0] == '#' && values[4] == 'Repository'

            values = values.map(&:strip)

            rows << Lock.new(
              values[0].to_i,
              values[1],
              values[2].to_i,
              values[3],
              values[4]
            )
          end

          rows
        end
      end

      def zypper_clean_locks(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'cleanlocks'

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_info(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'info'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          current_row = nil
          description = ''
          skip_description = false

          lines.each do |line|
            case line
            when /^Repository/
              repository = extract_single_zypper_line(line)
              next if repository == ''

              unless current_row.nil?
                skip_description = false
                current_row.description = description.strip
                description = ''
                rows << current_row
              end

              current_row = PackageDetail.new
              current_row.repository = repository
            when /^Name/
              current_row.package = extract_single_zypper_line(line)
            when /^Version/
              current_row.version = extract_single_zypper_line(line)
            when /^Arch/
              current_row.architecture = extract_single_zypper_line(line)
            when /^Vendor/
              current_row.vendor = extract_single_zypper_line(line)
            when /^Support Level/
              current_row.support_level = extract_single_zypper_line(line)
            when /^Installed Size/
              size = Kanrisuru::Util::Bits.normalize_size(extract_single_zypper_line(line))
              current_row.install_size = size
            when /^Installed/
              value = extract_single_zypper_line(line)
              current_row.installed = value == 'Yes'
            when /^Status/
              current_row.status = extract_single_zypper_line(line)
            when /^Source package/
              current_row.source_package = extract_single_zypper_line(line)
            when /^Summary/
              current_row.summary = extract_single_zypper_line(line)
            when /^Description/
              description = extract_single_zypper_line(line)
            when /^Builds binary package/, /^Contents/
              skip_description = true
            else
              next if line == ''
              next if line.include?('Information for package')
              next if line.include?('---------------------------')

              description += " #{line.strip}" unless skip_description
            end
          end

          if current_row
            current_row.description = description.strip
            rows << current_row
          end

          rows
        end
      end

      def zypper_install(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'install'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_arg('-n', opts[:name])
        command.append_arg('-f', opts[:force])
        command.append_flag('--oldpackage', opts[:oldpackage])
        command.append_arg('--from', opts[:from])
        command.append_arg('--capability', opts[:capability])
        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])
        command.append_flag('--replacefiles', opts[:replacefiles])

        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--allow-unsigned-rpm', opts[:allow_unsigned_rpm])

        zypper_solver_opts(command, opts)
        zypper_download_and_install_opts(command, opts)
        zypper_expert_opts(command, opts)

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_verify(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'verify'

        command.append_flag('--dry-run', opts[:dry_run])

        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_source_install(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'sourceinstall'

        zypper_repos_opt(command, opts)
        command.append_flag('--build-deps-only', opts[:build_deps_only])
        command.append_flag('--no-build-deps', opts[:no_build_deps])
        command.append_flag('--download-only', opts[:download_only])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_remove(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'remove'

        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--capability', opts[:capability])

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)
        zypper_solver_opts(command, opts)

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def zypper_install_new_recommends(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'install-new-recommends'

        command.append_flag('--dry-run', opts[:dry_run])

        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_purge_kernels(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'purge-kernels'
        command.append_flag('--dry-run', opts[:dry_run])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_search(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'search'

        command.append_flag('--details')
        command.append_flag('--match-substrings', opts[:match_substrings])
        command.append_flag('--match-words', opts[:match_words])
        command.append_flag('--match-exact', opts[:match_exact])
        command.append_flag('--provides', opts[:provides])
        command.append_flag('--requires', opts[:requires])
        command.append_flag('--recommends', opts[:recommends])
        command.append_flag('--suggests', opts[:suggests])
        command.append_flag('--conflicts', opts[:conflicts])
        command.append_flag('--obsoletes', opts[:obsoletes])
        command.append_flag('--supplements', opts[:supplements])
        command.append_flag('--provides-pkg', opts[:provides_pkg])
        command.append_flag('--requires-pkg', opts[:requires_pkg])
        command.append_flag('--recommends-pkg', opts[:recommends_pkg])
        command.append_flag('--supplements-pkg', opts[:supplements_pkg])
        command.append_flag('--conflicts-pkg', opts[:conflicts_pkg])
        command.append_flag('--obsoletes-pkg', opts[:obsoletes_pkg])
        command.append_flag('--suggests-pkg', opts[:suggests_pkg])
        command.append_flag('--name', opts[:name])
        command.append_flag('--file-list', opts[:file_list])
        command.append_flag('--search-descriptions', opts[:search_descriptions])
        command.append_flag('--case-sensitive', opts[:case_sensitive])
        command.append_flag('--installed-only', opts[:installed_only])
        command.append_flag('--not-installed-only', opts[:not_installed_only])
        command.append_flag('--sort-by-name', opts[:sort_by_name])
        command.append_flag('--sort-by-repo', opts[:sort_by_repo])

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next if line == ''

            values = line.split('|')
            next if values.length != 6

            values = values.map(&:strip)
            next if values[0] == 'S' && values[5] == 'Repository'

            rows << SearchResult.new(
              values[5],
              values[1],
              values[0],
              values[2],
              values[3],
              values[4]
            )
          end

          rows
        end
      end

      def zypper_update(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'update'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_flag('--replacefiles', opts[:replacefiles])
        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--best-effort', opts[:best_effort])

        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_list_updates(opts)
        return zypper_list_patches(opts) if opts[:type] == 'patch'

        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'list-updates'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_flag('--all', opts[:all])
        command.append_flag('--best-effort', opts[:best_effort])

        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift

          rows = []
          lines.each do |line|
            values = line.split(' | ')
            values = values.map(&:strip)

            rows << PackageUpdate.new(
              values[1],
              values[2],
              values[3],
              values[4],
              values[5]
            )
          end

          rows
        end
      end

      def zypper_list_patches(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'list-patches'

        command.append_arg('--bugzilla', opts[:bugzilla])
        command.append_arg('--cve', opts[:cve])
        command.append_arg('--date', opts[:date])

        zypper_patch_category_opt(command, opts)
        zypper_patch_severity_opt(command, opts)

        command.append_flag('--issues', opts[:issues])
        command.append_flag('--all', opts[:all])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])

        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift
          lines.shift

          rows = []
          lines.each do |line|
            next if line == ''

            values = line.split(' | ')
            next if values.length != 7

            values = values.map(&:strip)
            next if values[0] == 'Repository' && values[6] == 'Summary'

            rows << PatchUpdate.new(
              values[0],
              values[1],
              values[2],
              values[3],
              values[4] == '---' ? '' : values[4],
              values[5],
              values[6]
            )
          end

          rows
        end
      end

      def zypper_patch_check(opts)
        command = Kanrisuru::Command.new('zypper')
        command.append_valid_exit_code(EXIT_INF_UPDATE_NEEDED)
        command.append_valid_exit_code(EXIT_INF_SEC_UPDATE_NEEDED)

        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'patch-check'

        command.append_flag('--updatestack-only', opts[:updatestack_only])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])

        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next if line == ''

            values = line.split(' | ')
            next if values.length != 3

            values = values.map(&:strip)
            next if values[0] == 'Category'

            rows << PatchCount.new(
              values[0],
              values[1].to_i,
              values[2].to_i
            )
          end

          rows
        end
      end

      def zypper_patch(opts)
        command = Kanrisuru::Command.new('zypper')
        command.append_valid_exit_code(EXIT_INF_REBOOT_NEEDED)
        command.append_valid_exit_code(EXIT_INF_RESTART_NEEDED)
        zypper_global_opts(command, opts)

        command << 'patch'

        command.append_flag('--updatestack-only', opts[:updatestack_only])
        command.append_flag('--with-update', opts[:with_update])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])
        command.append_flag('--replacefiles', opts[:replacefiles])
        command.append_flag('--dry-run', opts[:dry_run])

        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])

        command.append_arg('--bugzilla', opts[:bugzilla])
        command.append_arg('--cve', opts[:cve])
        command.append_arg('--date', opts[:date])

        zypper_patch_category_opt(command, opts)
        zypper_patch_severity_opt(command, opts)
        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def zypper_dist_upgrade(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'dist-upgrade'

        command.append_flag('--auto-agree-with-licenses', opts[:auto_agree_with_licenses])
        command.append_flag('--auto-agree-with-product-licenses', opts[:auto_agree_with_product_licenses])
        command.append_flag('--dry-run', opts[:dry_run])

        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

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

      def extract_single_zypper_line(line)
        values = line.split(': ', 2)
        values.length == 2 ? values[1] : ''
      end
    end
  end
end
