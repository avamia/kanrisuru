module Kanrisuru
  module Core
    module Mount
      def mount(opts = {})
        type = opts[:type]

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
          command.append_flag('-f', opts[:fake])
          command.append_flag('-i', opts[:internal_only])
          command.append_flag('-s', opts[:sloppy])

          command.append_flag('--no-mtab', opts[:no_mtab])
          command.append_flag('--no-canonicalize', opts[:no_canonicalize])

          fs_options = nil
          if Kanrisuru::Util.present?(type)
            add_type(command, type)
            fs_options = Kanrisuru::Remote::Fstab::Options.new(type, fs_opts) if fs_opts
          elsif fs_opts
            fs_options = Kanrisuru::Remote::Fstab::Options.new('common', fs_opts)
          end

          if Kanrisuru::Util.present?(opts[:all])
            command.append_flag('-a')
            add_test_opts(command, opts[:test_opts], type)
          else
            command.append_arg('-o', fs_options.to_s)

            command << opts[:device] if Kanrisuru::Util.present?(opts[:device])
            command << opts[:directory] if Kanrisuru::Util.present?(opts[:directory])
          end
        end

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end