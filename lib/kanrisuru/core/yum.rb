# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module Yum
      extend OsPackage::Define

      os_define :fedora, :yum

      PackageOverview = Struct.new(:package, :architecture, :version, :installed)
      PackageSearchResult = Struct.new(:package, :architecture, :summary)
      PackageDetail = Struct.new(
        :package,
        :version,
        :release,
        :architecture,
        :install_size,
        :source,
        :yum_id,
        :repository,
        :summary,
        :url,
        :license,
        :description
      )

      Repolist = Struct.new(
        :id,
        :name,
        :status,
        :revision,
        :packages,
        :available_packages,
        :repo_size,
        :mirrors,
        :metalink,
        :updated,
        :baseurl,
        :expire,
        :filters,
        :filename
      )

      def yum(action, opts = {})
        case action
        when 'install'
          yum_install(opts)
        when 'localinstall'
          yum_localinstall(opts)
        when 'list'
          yum_list(opts)
        when 'search'
          yum_search(opts)
        when 'info'
          yum_info(opts)
        when 'repolist'
          yum_repolist(opts)
        when 'clean'
          yum_clean(opts)
        when 'remove'
          yum_remove(opts)
        when 'autoremove'
          yum_autoremove(opts)
        when 'erase'
          yum_erase(opts)
        when 'update'
          yum_update(opts)
        when 'upgrade'
          yum_upgrade(opts)
        end
      end

      private

      def yum_install(opts)
        command = Kanrisuru::Command.new('yum install')
        command.append_flag('-y')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_localinstall(opts)
        command = Kanrisuru::Command.new('yum localinstall')
        yum_disable_repo(command, opts[:disable_repo])
        command.append_flag('-y')

        if Kanrisuru::Util.present?(opts[:repos])
          repos = Kanrisuru::Util.string_join_array(opts[:repos], ' ')
          command << repos
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def yum_list(opts)
        command = Kanrisuru::Command.new('yum list')

        yum_disable_repo(command, opts[:disable_repo])

        command.append_flag('all', opts[:all])
        command.append_flag('available', opts[:available])
        command.append_flag('updates', opts[:updates])
        command.append_flag('installed', opts[:installed])
        command.append_flag('extras', opts[:extras])
        command.append_flag('obsoletes', opts[:obsoletes])

        command << opts[:query] if Kanrisuru::Util.present?(opts[:query])

        pipe_output_newline(command)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          result = []
          lines.each do |line|
            item = parse_yum_line(line)
            next unless item

            result << item
          end

          result
        end
      end

      def yum_remove(opts)
        command = Kanrisuru::Command.new('yum remove')
        command.append_flag('-y')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        raise ArugmentError, "can't remove yum" if packages.include?('yum')

        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_clean(opts)
        command = Kanrisuru::Command.new('yum clean')

        command.append_flag('dbcache', opts[:dbcache])
        command.append_flag('expire-cache', opts[:expire_cache])
        command.append_flag('metadata', opts[:metadata])
        command.append_flag('packages', opts[:packages])
        command.append_flag('headers', opts[:headers])
        command.append_flag('rpmdb', opts[:rpmdb])
        command.append_flag('all', opts[:all])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def yum_autoremove(_opts)
        command = Kanrisuru::Command.new('yum autoremove')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_erase(opts)
        command = Kanrisuru::Command.new('yum erase')
        command.append_flag('-y')

        packages = Kanrisuru::Util.string_join_array(opts[:packages], ' ')
        raise ArugmentError, "can't erase yum" if packages.include?('yum')

        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_update(_opts)
        command = Kanrisuru::Command.new('yum update')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_upgrade(_opts)
        command = Kanrisuru::Command.new('yum upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def yum_search(opts)
        command = Kanrisuru::Command.new('yum search')
        command.append_flag('all', opts[:all])
        command << Kanrisuru::Util.string_join_array(opts[:packages], ' ')

        pipe_output_newline(command)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          result = []
          lines.each do |line|
            line = line.gsub(/\s{2}/, '')
            values = line.split(' : ')
            next if values.length != 2

            full_name = values[0]
            name, architecture = full_name.split('.')
            summary = values[1]

            result << PackageSearchResult.new(name, architecture, summary)
          end

          result
        end
      end

      def yum_repolist(opts)
        command = Kanrisuru::Command.new('yum repolist')
        command.append_flag('--verbose')

        command << Kanrisuru::Util.string_join_array(opts[:repos], ' ') if opts[:repos]

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

      def yum_info(opts)
        command = Kanrisuru::Command.new('yum info')
        command.append_flag('--quiet')
        command.append_flag('installed', opts[:installed])

        command << Kanrisuru::Util.string_join_array(opts[:packages], ' ') if opts[:packages]

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

      def extract_single_yum_line(line)
        values = line.split(': ', 2)
        values.length == 2 ? values[1] : ''
      end

      def parse_yum_line(line)
        values = line.split
        return if values.length != 3
        return unless /^\w+\.\w+$/i.match(values[0])

        full_name = values[0]
        version = values[1]

        name, architecture = full_name.split('.')

        PackageOverview.new(name, architecture, version)
      end

      ## Bug reported on the output of the yum command
      ## https://bugzilla.redhat.com/show_bug.cgi?id=584525
      ## that autowraps text when used in a script beyond 80 chars wide.
      ## Work-around with formatting by
      ## piping through trimming extra newline chars.
      def pipe_output_newline(command)
        command | "tr '\\n' '#'"
        command | "sed -e 's/# / /g'"
        command | "tr '#' '\\n'"
      end

      def yum_disable_repo(command, repo)
        return unless Kanrisuru::Util.present?(repo)

        command.append_flag("--disablerepo=#{repo}")
      end
    end
  end
end
