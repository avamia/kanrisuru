module Kanrisuru
  module Core
    module Apt
      def apt_show(opts)
        command = Kanrisuru::Command.new('apt show')
        command.append_flag('-a')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          rows = []

          current_row = nil
          description = ''

          lines.each do |line|
            next if line == 'WARNING: apt does not have a stable CLI interface. Use with caution in scripts.'
            next if ['', nil, '.'].include?(line)

            case line
            when /^Package:/
              unless current_row.nil?
                current_row.description = description.strip
                description = ''
                rows << current_row
              end

              current_row = PackageDetail.new
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
              size = Kanrisuru::Util::Bits.normalize_size(extract_single_line(line))
              current_row.install_size = size
            when /^Download-Size:/
              size = Kanrisuru::Util::Bits.normalize_size(extract_single_line(line))
              current_row.download_size = size
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
              current_row.summary = extract_single_line(line)
            else
              description += " #{line.strip}"
            end
          end

          current_row.description = description.strip
          rows << current_row
          rows
        end
      end
    end
  end
end