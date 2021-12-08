module Kanrisuru
  module Core
    module Yum
      def yum_repolist(opts)
        command = Kanrisuru::Command.new('yum repolist')
        command.append_flag('--verbose')

        command << Kanrisuru::Util.array_join_string(opts[:repos], ' ') if opts[:repos]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          current_row = nil

          lines.each do |line|
            case line
            when /^Repo-id/
              if current_row
                rows << current_row
                current_row = nil
              end

              current_row = Repolist.new
              current_row.id = extract_single_yum_line(line)
            when /^Repo-name/
              current_row.name = extract_single_yum_line(line)
            when /^Repo-revision/
              current_row.revision = extract_single_yum_line(line).to_i
            when /^Repo-updated/, /^Updated/
              text = extract_single_yum_line(line)
              current_row.updated = DateTime.parse(text)
            when /^Repo-pkgs/
              current_row.packages = extract_single_yum_line(line).to_i
            when /^Repo-size/
              size = Kanrisuru::Util::Bits.normalize_size(extract_single_yum_line(line))
              current_row.repo_size = size
            when /^Repo-mirrors/
              current_row.mirrors = extract_single_yum_line(line)
            when /^Repo-metalink/
              current_row.metalink = extract_single_yum_line(line)
            when /^Repo-baseurl/
              current_row.baseurl = extract_single_yum_line(line).split[0]
            when /^Repo-expire/
              current_row.expire = extract_single_yum_line(line)
            when /^Repo-filename/
              current_row.filename = extract_single_yum_line(line)
            when /^Repo-available-pkgs/
              current_row.available_packages = extract_single_yum_line(line).to_i
            when /^Filter/
              current_row.filters = extract_single_yum_line(line)
            end
          end

          rows << current_row
          rows
        end
      end
    end
  end
end