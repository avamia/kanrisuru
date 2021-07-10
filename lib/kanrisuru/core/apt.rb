# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      extend OsPackage::Define

      os_define :debian, :apt

      AptSource = Struct.new(:url, :dist, :architecture)
      AptPackageOverview = Struct.new(:package, :version, :suites, :architecture, :installed, :upgradeable, :automatic)
      AptPackageDetail = Struct.new(
        :package,
        :version,
        :priority,
        :section,
        :origin,
        :maintainer,
        :original_maintainer,
        :bugs,
        :install_size,
        :dependencies,
        :recommends,
        :provides,
        :suggests,
        :breaks,
        :conflicts,
        :replaces,
        :homepage,
        :task,
        :supported,
        :download_size,
        :apt_manual_installed,
        :apt_sources,
        :description,
        :summary
      )

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

      private

      def apt_autoclean(_opts)
        command = Kanrisuru::Command.new('apt-get autoclean')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_clean(_opts)
        command = Kanrisuru::Command.new('apt-get clean')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_search(opts)
        command = Kanrisuru::Command.new('apt search')
        command << opts[:query]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift
          lines.shift

          result = []

          lines.each do |line|
            next unless line.include?('/')

            item = parse_apt_line(line)
            next unless item

            result << item
          end

          result
        end
      end

      def apt_list(opts)
        command = Kanrisuru::Command.new('apt list')
        command.append_flag('--installed', opts[:installed])
        command.append_flag('--upgradeable', opts[:upgradeable])
        command.append_flag('--all-versions', opts[:all_versions])
        command.append_arg('-a', opts[:package_name])

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift

          result = []
          lines.each.with_index do |line, _index|
            item = parse_apt_line(line)
            next unless item

            result << item
          end

          result
        end
      end

      def apt_autoremove(_opts)
        command = Kanrisuru::Command.new('apt-get autoremove')
        command.append_flag('-y')

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_purge(opts)
        command = Kanrisuru::Command.new('apt-get purge')
        command.append_flag('-y')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_remove(opts)
        command = Kanrisuru::Command.new('apt-get remove')
        command.append_flag('-y')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_install(opts)
        command = Kanrisuru::Command.new('apt-get install')
        command.append_flag('-y')

        command.append_flag('--no-upgrade', opts[:no_upgrade])
        command.append_flag('--only-upgrade', opts[:only_upgrade])
        command.append_flag('--reinstall', opts[:reinstall])

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_full_upgrade(_opts)
        command = Kanrisuru::Command.new('apt full-upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_upgrade(_opts)
        command = Kanrisuru::Command.new('apt-get upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_update(_opts)
        command = Kanrisuru::Command.new('apt-get update')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def apt_show(opts)
        command = Kanrisuru::Command.new('apt show')
        command.append_flag('-a')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          rows = []

          current_row = nil
          summary = ''

          lines.each do |line|
            next if line == 'WARNING: apt does not have a stable CLI interface. Use with caution in scripts.'
            next if [] ['', nil, '.'].include?(line)

            case line
            when /^Package:/
              unless current_row.nil?
                current_row.summary = summary.strip
                summary = ''
                rows << current_row
              end

              current_row = AptPackageDetail.new
              current_row.package = extract_single_line(line)
            when /^Version:/
              current_row.version = extract_single_line(line)
            when /^Priority:/
              current_row.priority = extract_single_line(line)
            when /^Section:/
              current_row.section = extract_single_line(line)
            when /^Origin:/
              current_row.origin = extract_single_line(line)
            when /^Maintainer:/
              current_row.maintainer = extract_single_line(line)
            when /^Original-Maintainer:/
              current_row.original_maintainer = extract_single_line(line)
            when /^Bugs:/
              current_row.bugs = extract_single_line(line)
            when /^Installed-Size:/
              current_row.install_size = normalize_size(extract_single_line(line))
            when /^Download-Size:/
              current_row.download_size = normalize_size(extract_single_line(line))
            when /^Depends:/
              current_row.dependencies = parse_comma_values(extract_single_line(line))
            when /^Provides:/
              current_row.provides = parse_comma_values(extract_single_line(line))
            when /^Recommends:/
              current_row.recommends = parse_comma_values(extract_single_line(line))
            when /^Suggests:/
              current_row.suggests = parse_comma_values(extract_single_line(line))
            when /^Breaks:/
              current_row.breaks = parse_comma_values(extract_single_line(line))
            when /^Conflicts:/
              current_row.conflicts = parse_comma_values(extract_single_line(line))
            when /^Replaces:/
              current_row.replaces = parse_comma_values(extract_single_line(line))
            when /^Homepage:/
              current_row.homepage = extract_single_line(line)
            when /^Task:/
              current_row.task = parse_comma_values(extract_single_line(line))
            when /^Supported:/
              current_row.supported = extract_single_line(line)
            when /^APT-Sources:/
              current_row.apt_sources = parse_apt_sources(extract_single_line(line))
            when /^APT-Manual-Installed:/
              current_row.apt_manual_installed = extract_single_line(line) == 'yes'
            when /^Description:/
              current_row.description = extract_single_line(line)
            else
              summary += " #{line.strip}"
            end
          end

          current_row.summary = summary.strip
          rows << current_row
          rows
        end
      end

      def extract_single_line(line)
        line.split(': ')[1]
      end

      def parse_comma_values(string)
        string.split(', ')
      end

      def parse_apt_sources(string)
        url, dist, architecture, = string.split
        AptSource.new(url, dist, architecture)
      end

      def normalize_size(string)
        size, unit = string.split
        size = size.to_i
        case unit.downcase
        when 'b'
          Kanrisuru::Util::Bits.convert_bytes(size, :byte, :kilobyte)
        when 'kb'
          size
        when 'mb'
          Kanrisuru::Util::Bits.convert_from_mb(size, :kilobyte).to_i
        when 'gb'
          Kanrisuru::Util::Bits.convert_from_gb(size, :kilobyte).to_i
        end
      end

      def parse_apt_line(line)
        values = line.split('/')
        return if values.length < 2

        package = values[0]

        values = values[1].split
        suites = values[0].split(',')
        version = values[1]
        architecture = values[2]

        installed = false
        upgradeable = false
        automatic = false

        if values.length > 3
          installed = values[3].include?('installed')
          upgradeable = values[3].include?('upgradeable')
          automatic = values[3].include?('automatic')
        end

        AptPackageOverview.new(package, version, suites, architecture, installed, upgradeable, automatic)
      end
    end
  end
end
