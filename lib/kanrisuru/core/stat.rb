# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module Stat
      extend OsPackage::Define

      os_define :linux, :dir?
      os_define :linux, :file?
      os_define :linux, :block_device?
      os_define :linux, :char_device?
      os_define :linux, :symlink?
      os_define :linux, :file_type?
      os_define :linux, :inode?
      os_define :linux, :stat

      FileStat = Struct.new(
        :mode, :blocks, :device, :file_type,
        :gid, :group, :links, :inode,
        :path, :fsize, :uid, :user,
        :last_access, :last_modified, :last_changed
      )

      def dir?(path)
        file_type?(path, 'directory')
      end

      def file?(path)
        file_type?(path, 'regular file')
      end

      def empty_file?(path)
        file_type?(path, 'regular empty file')
      end

      def block_device?(path)
        file_type?(path, 'block special file')
      end

      def char_device?(path)
        file_type?(path, 'character special file')
      end

      def symlink?(path)
        file_type?(path, 'symbolic link')
      end

      def inode?(path)
        command = Kanrisuru::Command.new("stat #{path}")
        command.append_arg('-c', '%i')
        execute(command)
        command.success?
      end

      def file_type?(path, type)
        command = Kanrisuru::Command.new("stat #{path}")
        command.append_arg('-c', '%F')

        execute(command)

        result = Kanrisuru::Result.new(command, &:to_s)

        result.success? ? result.data == type : false
      end

      def stat(path, opts = {})
        follow = opts[:follow]

        command = Kanrisuru::Command.new('stat')
        command.append_flag('-L', follow)
        command.append_arg('-c', '%A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z')
        command << path

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          string = cmd.to_s
          values = string.split(',')

          FileStat.new(
            Kanrisuru::Mode.new(values[0]),
            values[1].to_i,
            values[2],
            values[3],
            values[4].to_i,
            values[5],
            values[6].to_i,
            values[7].to_i,
            values[8],
            values[9].to_i,
            values[10].to_i,
            values[11],
            values[12] ? DateTime.parse(values[12]) : nil,
            values[13] ? DateTime.parse(values[13]) : nil,
            values[14] ? DateTime.parse(values[14]) : nil
          )
        end
      end
    end
  end
end
