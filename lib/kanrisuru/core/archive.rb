# frozen_string_literal: true

module Kanrisuru
  module Core
    module Archive
      extend OsPackage::Define

      os_define :linux, :tar

      FilePath = Struct.new(:path)

      def tar(action, file, opts = {})
        compress    = opts[:compress]
        paths       = opts[:paths]
        exclude     = opts[:exclude]
        directory   = opts[:directory]

        command = Kanrisuru::Command.new('tar --restrict')

        directory = realpath(directory, strip: true).path if directory
        command.append_arg('-C', directory)
        command.append_arg('-f', file)

        set_compression(command, compress) if compress

        case action
        when 'list', 't'
          command.append_flag('-t')
          command.append_arg('--occurrence', opts[:occurrence])
          command.append_flag('--label', opts[:label])
          command.append_flag('--multi-volume', opts[:multi_volume])

          execute_shell(command)
          Kanrisuru::Result.new(command) do |cmd|
            items = cmd.to_a

            items.map do |item|
              FilePath.new(item)
            end
          end
        when 'extract', 'get', 'x'
          command.append_flag('-x')
          command.append_arg('--occurrence', opts[:occurrence])

          command.append_flag('--no-same-owner', opts[:no_same_owner])
          command.append_flag('--no-same-permissions', opts[:no_same_permissions])
          command.append_flag('--no-selinux', opts[:no_selinux])
          command.append_flag('--no-xattrs', opts[:no_xattrs])
          command.append_flag('--preserve-permissions', opts[:preserve_permissions])
          command.append_flag('--same-owner', opts[:same_owners])
          command.append_flag('--multi-volume', opts[:multi_volume])
          command.append_flag('--label', opts[:label])
          command.append_flag('--one-file-system ', opts[:one_file_system])
          command.append_flag('--keep-old-files', opts[:keep_old_files])
          command.append_flag('--skip-old-files', opts[:skip_old_files])
          command.append_flag('--overwrite', opts[:overwrite])
          command.append_flag('--overwrite-dir', opts[:overwrite_dir])
          command.append_flag('--unlink-first', opts[:unlink_first])
          command.append_flag('--recursive-unlink', opts[:recursive_unlink])

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)
          Kanrisuru::Result.new(command)
        when 'create', 'c'
          command.append_flag('-c')
          command.append_flag('--multi-volume', opts[:multi_volume])

          if Kanrisuru::Util.present?(exclude)
            exclude = exclude.instance_of?(String) ? [exclude] : exclude
            command.append_arg('--exclude', exclude.join(' '))
          end

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of?(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)

          Kanrisuru::Result.new(command)
        when 'append', 'r'
          command.append_flag('-r')

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of?(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)
          Kanrisuru::Result.new(command)
        when 'catenate', 'concat', 'A'
          command.append_flag('-A')

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of?(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)
          Kanrisuru::Result.new(command)
        when 'update', 'u'
          command.append_flag('-u')

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of?(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)
          Kanrisuru::Result.new(command)
        when 'diff', 'compare', 'd'
          command.append_flag('-d')
          command.append_arg('--occurrence', opts[:occurrence])

          execute_shell(command)
          Kanrisuru::Result.new(command)
        when 'delete'
          command.append_flag('--delete')
          command.append_arg('--occurrence', opts[:occurrence])

          if Kanrisuru::Util.present?(paths)
            paths = paths.instance_of?(String) ? [paths] : paths
            command << paths.join(' ')
          end

          execute_shell(command)
          Kanrisuru::Result.new(command)
        else
          raise ArgumentError, 'Invalid argument action'
        end
      end

      private

      def set_compression(command, compress)
        case compress
        when 'bzip2'
          command.append_flag('-j')
        when 'xz'
          command.append_flag('-J')
        when 'gzip'
          command.append_flag('-z')
        when 'lzma'
          command.append_flag('--lzma')
        else
          raise ArgumentError, "Invalid copmression program: #{compress}"
        end
      end
    end
  end
end
