module Kanrisuru
  module Core
    module Yum
      def yum_info(opts)
        command = Kanrisuru::Command.new('yum info')
        command.append_flag('--quiet')
        command.append_flag('installed', opts[:installed])

        command << Kanrisuru::Util.array_join_string(opts[:packages], ' ') if opts[:packages]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          current_row = nil
          description = ''

          lines.each do |line|
            next unless line.include?(': ')

            case line
            when /^Name/
              unless current_row.nil?
                current_row.description = description.strip
                description = ''
                rows << current_row
              end

              current_row = PackageDetail.new
              current_row.package = extract_single_yum_line(line)
            when /^Arch/, /^Architecture/
              current_row.architecture = extract_single_yum_line(line)
            when /^Version/
              current_row.version = extract_single_yum_line(line)
            when /^Release/
              current_row.release = extract_single_yum_line(line)
            when /^Source/
              current_row.source = extract_single_yum_line(line)
            when /^Repository/
              current_row.repository = extract_single_yum_line(line)
            when /^Summary/
              current_row.summary = extract_single_yum_line(line)
            when /^URL/, /^Url/
              current_row.url = extract_single_yum_line(line)
            when /^License/
              current_row.license = extract_single_yum_line(line)
            when /^From repo/
              current_row.yum_id = extract_single_yum_line(line)
            when /^Size/
              size = Kanrisuru::Util::Bits.normalize_size(extract_single_yum_line(line))
              current_row.install_size = size
            when /^Description/
              description = extract_single_yum_line(line)
            else
              next if line == ''

              description += " #{extract_single_yum_line(line).strip}"
            end
          end

          if current_row
            current_row.description = description.strip
            rows << current_row
          end

          rows
        end
      end
    end
  end
end