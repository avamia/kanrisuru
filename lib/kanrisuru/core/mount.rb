# frozen_string_literal: true

module Kanrisuru
  module Core
    module Mount
      extend OsPackage::Define

      os_define :linux, :mount
      os_define :linux, :umount

      def mount(opts = {})
        type = opts[:type]
        all  = opts[:all]
        device = opts[:device]
        directory = opts[:directory]

        bind_old = opts[:bind_old]
        bind_new = opts[:bind_new]
        rbind_old = opts[:rbind_old]
        rbind_new = opts[:rbind_new]
        move_old = opts[:move_old]
        move_new = opts[:move_new]
        fs_opts   = opts[:fs_opts]

        command = Kanrisuru::Command.new('mount')

        if Kanrisuru::Util.present?(bind_old) && Kanrisuru::Util.present?(bind_new)
          command.append_flag('--bind')
          command << bind_old
          command << bind_new
        elsif Kanrisuru::Util.present?(rbind_old) && Kanrisuru::Util.present?(rbind_new)
          command.append_flag('--rbind')
          command << rbind_old
          command << rbind_new
        elsif Kanrisuru::Util.present?(move_old) && Kanrisuru::Util.present?(move_new)
          command.append_flag('--move')
          command << move_old
          command << move_new
        else
          command.append_arg('-L', opts[:label])
          command.append_arg('-U', opts[:uuid])
          command.append_flag('-n', opts[:no_mtab])
          command.append_flag('-f', opts[:fake])
          command.append_flag('-i', opts[:internal_only])
          command.append_flag('-s', opts[:sloppy])

          command.append_flag('--no-mtab', opts[:no_mtab])
          command.append_flag('--no-canonicalizeb', opts[:no_canonicalize])

          fs_options = nil
          if Kanrisuru::Util.present?(type)
            add_type(command, type)
            fs_options = Kanrisuru::Remote::Fstab::Options.new(type, fs_opts) if fs_opts
          elsif fs_opts
            fs_options = Kanrisuru::Remote::Fstab::Options.new('common', fs_opts)
          end

          if Kanrisuru::Util.present?(all)
            command.append_flag('-a')
            add_test_opts(command, opts[:test_opts], type)
          else
            command.append_arg('-o', fs_options.to_s)

            command << device if Kanrisuru::Util.present?(device)
            command << directory if Kanrisuru::Util.present?(directory)
          end
        end

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def umount(opts = {})
        all = opts[:all]
        type = opts[:type]
        command = Kanrisuru::Command.new('umount')

        if Kanrisuru::Util.present?(all)
          command.append_flag('-a')
          add_type(command, type)
          add_test_opts(command, opts[:test_opts], type)
        end

        command.append_flag('--fake', opts[:fake])
        command.append_flag('--no-canonicalize', opts[:no_canonicalize])
        command.append_flag('-n', opts[:no_mtab])
        command.append_flag('-r', opts[:fail_remount_readonly])
        command.append_flag('-d', opts[:free_loopback])

        command.append_flag('-l', opts[:lazy])
        command.append_flag('-f', opts[:force])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      private

      def add_type(command, type)
        return unless Kanrisuru::Util.present?(type)

        test_types = nil

        if type.include?(',')
          if type.include?('no')
            test_types = type.gsub('no', '')
            test_types = test_types.split(',')
          else
            test_types = type.split(',')
          end
        else
          test_types = [type]
        end

        test_types.each do |t|
          device_opts = Kanrisuru::Util::FsMountOpts.get_device(t)
          raise ArugmentError, "Invalid fstype: #{t}" unless device_opts
        end

        command.append_arg('-t', type)
      end

      def add_test_opts(command, test_opts, type)
        return unless Kanrisuru::Util.present?(test_opts)

        test_options =
          if Kanrisuru::Util.present?(type)
            Kanrisuru::Remote::Fstab::Options.new(type, test_opts)
          else
            Kanrisuru::Remote::Fstab::Options.new('common', test_opts)
          end

        command.append_arg('-O', test_options.to_s)
      end
    end
  end
end
