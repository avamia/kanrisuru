# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Os
      attr_reader :processor, :operating_system, :release, :version

      def initialize(host)
        Kanrisuru.logger.info('Gathering OS details')

        @host = host
        @kernel_name = uname(kernel_name: true)

        case @kernel_name
        when 'Linux'
          initialize_linux
        end
      end

      def kernel
        @kernel_name
      end

      def linux?
        kernel == 'Linux'
      end

      def uname(opts = {})
        command = Kanrisuru::Command.new('uname')

        if opts[:all]
          command.append_flag('-a', opts[:all])
        else
          command.append_flag('-s', opts[:kernel_name])
          command.append_flag('-n', opts[:node_name])
          command.append_flag('-r', opts[:kernel_release])
          command.append_flag('-v', opts[:kernel_version])
          command.append_flag('-m', opts[:machine])
          command.append_flag('-p', opts[:processor])
          command.append_flag('-i', opts[:hardware_platform])
          command.append_flag('-o', opts[:operating_system])
        end

        @host.execute(command)

        return unless command.success?

        if opts.keys.length > 1 || opts[:all]
          command.to_a
        else
          command.to_s
        end
      end

      private

      def initialize_linux
        @kernel_version   = uname(kernel_version: true)
        machine           = uname(machine: true)
        processor         = uname(processor: true)
        @operating_system  = uname(operating_system: true)
        @hardware_platform = uname(hardware_platform: true)

        @processor = processor == 'unknown' ? machine : processor

        @release = parse_os_release
        @version = parse_os_version
      end

      def parse_os_release
        command = Kanrisuru::Command.new("cat /etc/os-release | grep '^ID=' | awk -F= '{ print $2}'")
        result = @host.execute(command)
        raise 'Invalid os release' if result.failure?

        value = result.to_s
        value = value.gsub(/"/, '')
        value.gsub('-', '_')
      end

      def parse_os_version
        command = Kanrisuru::Command.new("cat /etc/os-release | grep '^VERSION_ID=' | awk -F= '{ print $2}'")
        result = @host.execute(command)
        raise 'Invalid os version' if result.failure?

        result.to_s.gsub(/"/, '').to_f
      end
    end
  end
end
