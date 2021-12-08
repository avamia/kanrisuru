require_relative 'commands/mount'
require_relative 'commands/umount'

module Kanrisuru
  module Core
    module Mount
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
          raise ArgumentError, "Invalid fstype: #{t}" unless device_opts
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