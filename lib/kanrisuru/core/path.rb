# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module Path
      extend OsPackage::Define

      os_define :linux, :ls
      os_define :linux, :pwd
      os_define :linux, :realpath
      os_define :linux, :readlink
      os_define :linux, :whoami
      os_define :linux, :which

      FilePath = Struct.new(:path)
      FileInfoId = Struct.new(:inode, :mode, :hard_links, :uid, :gid, :fsize, :date, :path, :type)
      FileInfo = Struct.new(:inode, :mode, :hard_links, :owner, :group, :fsize, :date, :path, :type)
      UserName = Struct.new(:user)

      def ls(opts = {})
        path = opts[:path]
        all  = opts[:all]
        id   = opts[:id]

        command = Kanrisuru::Command.new('ls')
        command.append_flag('-i')
        command.append_flag('-l')
        command.append_flag('-a', all)
        command.append_flag('-n', id)

        command << (path || pwd.path)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          items = []
          rows = cmd.to_a

          rows.each.with_index do |row, index|
            next if index.zero?

            values = row.split
            date = DateTime.parse("#{values[6]} #{values[7]} #{values[8]}")

            type = values[1].include?('d') ? 'directory' : 'file'
            items <<
              if id
                FileInfo.new(
                  values[0].to_i,
                  Kanrisuru::Mode.new(values[1]),
                  values[2].to_i,
                  values[3].to_i,
                  values[4].to_i,
                  values[5].to_i,
                  date,
                  values[9],
                  type
                )
              else
                FileInfo.new(
                  values[0].to_i,
                  Kanrisuru::Mode.new(values[1]),
                  values[2].to_i,
                  values[3],
                  values[4],
                  values[5].to_i,
                  date,
                  values[9],
                  type
                )
              end
          end

          items
        end
      end

      def whoami
        command = Kanrisuru::Command.new('whoami')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          UserName.new(cmd.to_s)
        end
      end

      def pwd
        command = Kanrisuru::Command.new('pwd')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end

      def which(program, opts = {})
        command = Kanrisuru::Command.new('which')
        command.append_flag('-a', opts[:all])
        command << program

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          rows = cmd.to_a
          rows.map do |row|
            FilePath.new(row)
          end
        end
      end

      def realpath(path, opts = {})
        command = Kanrisuru::Command.new("realpath #{path}")
        command.append_flag('-s', opts[:strip])

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end

      def readlink(path, opts = {})
        command = Kanrisuru::Command.new('readlink')
        command.append_flag('-f', opts[:canonicalize])
        command.append_flag('-e', opts[:canonicalize_existing])
        command.append_flag('-m', opts[:canonicalize_missing])

        command << path

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end
    end
  end
end
