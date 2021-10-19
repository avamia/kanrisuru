# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module Find
      extend OsPackage::Define

      os_define :linux, :find

      FilePath = Struct.new(:path)
      REGEX_TYPES = ['emacs', 'posix-awk', 'posix-basic', 'posix-egrep', 'posix-extended']

      def find(opts = {})
        paths      = opts[:paths]
        type       = opts[:type]
        regex      = opts[:regex]
        size       = opts[:size]

        command = Kanrisuru::Command.new('find')

        case opts[:follow]
        when 'never'
          command.append_flag('-P')
        when 'always'
          command.append_flag('-L')
        when 'command'
          command.append_flag('-H')
        end

        if Kanrisuru::Util.present?(paths)
          if paths.instance_of?(Array)
            paths = paths.join(' ')
          elsif paths.class != String
            raise ArgumentError, 'Invalid paths type'
          end

          command << paths
        end

        command.append_flag('-executable', opts[:executable])
        command.append_flag('-empty', opts[:empty])
        command.append_flag('-readable', opts[:readable])
        command.append_flag('-writable', opts[:writable])
        command.append_flag('-nogroup', opts[:nogroup])
        command.append_flag('-nouser', opts[:nouser])
        command.append_flag('-mount', opts[:mount])

        command.append_arg('-path', opts[:path])
        command.append_arg('-name', opts[:name])
        command.append_arg('-gid', opts[:gid])
        command.append_arg('-uid', opts[:uid])
        command.append_arg('-user', opts[:user])
        command.append_arg('-group', opts[:group])
        command.append_arg('-inum', opts[:inode])
        command.append_arg('-links', opts[:links])
        command.append_arg('-maxdepth', opts[:maxdepth])
        command.append_arg('-mindepth', opts[:mindepth])

        command.append_arg('-atime', opts[:atime])
        command.append_arg('-ctime', opts[:ctime])
        command.append_arg('-mtime', opts[:mtime])
        command.append_arg('-amin', opts[:amin])
        command.append_arg('-cmin', opts[:cmin])
        command.append_arg('-mmin', opts[:mmin])

        if Kanrisuru::Util.present?(opts[:regex_type])
          unless REGEX_TYPES.include?(opts[:regex_type])
            raise ArgumentError, 'invalid regex type'
          end

          command.append_arg('-regextype', opts[:regex_type])
        end

        command.append_arg('-regex', "'#{regex}'") if Kanrisuru::Util.present?(regex)

        if size.instance_of?(String)
          regex = Regexp.new(/^([-+])?(\d+)([bcwkMG])*$/)
          raise ArgumentError, "invalid size string: '#{@size}'" unless regex.match?(size) 
          command.append_arg('-size', size)
        elsif size.instance_of?(Integer)
          command.append_arg('-size', size)
        end

        case type
        when 'directory'
          command.append_arg('-type', 'd')
        when 'file'
          command.append_arg('-type', 'f')
        when 'symlinks'
          command.append_arg('-type', 'l')
        when 'block'
          command.append_arg('-type', 'b')
        when 'character'
          command.append_arg('-type', 'c')
        when 'pipe'
          command.append_arg('-type', 'p')
        when 'socket'
          command.append_arg('-type', 's')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          rows = cmd.to_a

          rows.map do |row|
            FilePath.new(row)
          end
        end
      end
    end
  end
end
