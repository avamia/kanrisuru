# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def symlink(src, dest, opts = {})
        ln_s(src, dest, opts)
      end

      def ln_s(src, dest, opts = {})
        return if src == dest

        ## Use absolute path for source
        real_src = realpath(src).path

        ## Not valid if no real path, not an existing inode, or root
        raise ArgumentError, 'Invalid path' if Kanrisuru::Util.blank?(real_src) || !inode?(real_src) || real_src == '/'

        dest_is_dir = dir?(dest)

        ## Don't symlink inside an already existing symlink
        return if symlink?(dest) && dest_is_dir

        real_dest =
          if dest_is_dir
            ## Use real path for destination
            realpath(dest).path
          else
            ## Use standard path
            dest
          end

        return unless real_dest

        command = Kanrisuru::Command.new("ln -s #{real_src} #{real_dest}")
        command.append_flag('-f', opts[:force])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(real_dest).data
        end
      end
    end
  end
end
