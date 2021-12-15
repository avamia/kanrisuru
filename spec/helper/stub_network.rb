# frozen_string_literal: true

class StubNetwork
  class << self
    def stub!(os_type = 'ubuntu')
      unless Kanrisuru::Remote::Host.instance_methods(false).include?(:execute_with_retries_alias)
        Kanrisuru::Remote::Host.class_eval do
          alias_method :execute_with_retries_alias, :execute_with_retries
          def execute_with_retries(command)
            command.handle_status(0)
            command.handle_data(nil)

            command
          end
        end
      end

      unless Kanrisuru::Remote::Os.instance_methods(false).include?(:initialize_alias)
        Kanrisuru::Remote::Os.class_eval do
          alias_method :initialize_alias, :initialize
          define_method :initialize do |host|
            @host = host

            @kernel_name       = StubNetwork.send(:os_defaults, os_type, :kernel_name)
            @kernel_version    = StubNetwork.send(:os_defaults, os_type, :kernel_version)
            @operating_system  = StubNetwork.send(:os_defaults, os_type, :operating_system)
            @hardware_platform = StubNetwork.send(:os_defaults, os_type, :hardware_platform)
            @processor         = StubNetwork.send(:os_defaults, os_type, :processor)
            @release           = StubNetwork.send(:os_defaults, os_type, :release)
            @version           = StubNetwork.send(:os_defaults, os_type, :version)
          end
        end
      end

      return if Kanrisuru::Result.instance_methods(false).include?(:initialize_alias)

      Kanrisuru::Result.class_eval do
        alias_method :initialize_alias, :initialize
        def initialize(command, parse_result = false, &block)
          @command = command
          @data = nil

          @data = block.call(@command) if @command.success? && block_given? && parse_result
          @error = @command.to_a if @command.failure?

          ## Define getter methods on result that maps to
          ## the same methods of a data struct.
          return unless @command.success? && Kanrisuru::Util.present?(@data) && @data.class.ancestors.include?(Struct)

          method_names = @data.members
          self.class.class_eval do
            method_names.each do |method_name|
              define_method method_name do
                @data[method_name]
              end
            end
          end
        end
      end
    end

    def stub_command!(method, opts = {}, &block)
      Kanrisuru::Remote::Host.class_eval do
        alias_method "#{method}_alias", method

        define_method(method) do |*args|
          command = Kanrisuru::Command.new(method.to_s)

          status = opts[:status] || 0
          command.handle_status(status)

          if opts[:return_value].nil?
            Kanrisuru::Result.new(command, true) do |_cmd|
              block.call(args)
            end
          else
            opts[:return_value]
          end
        end
      end
    end

    def unstub_command!(method)
      Kanrisuru::Remote::Host.class_eval do
        alias_method method, "#{method}_alias"
      end
    end

    def unstub!
      Kanrisuru::Remote::Host.class_eval do
        alias_method :execute_with_retries, :execute_with_retries_alias
      end

      Kanrisuru::Remote::Os.class_eval do
        alias_method :initialize, :initialize_alias
      end

      Kanrisuru::Result.class_eval do
        alias_method :initialize, :initialize_alias
      end
    end

    private

    def os_defaults(name, property)
      name = name.to_sym

      defaults = {
        ubuntu: {
          kernel_name: 'Linux',
          kernel_version: '#91-Ubuntu SMP Thu Jul 15 19:09:17 UTC 2021',
          operating_system: 'GNU/Linux',
          hardware_platform: 'x86_64',
          processor: 'x86_64',
          release: 'ubuntu',
          version: 20.0
        },
        centos: {
          kernel_name: 'Linux',
          kernel_version: '"#1 SMP Wed Jul 21 11:57:15 UTC 2021"',
          operating_system: 'GNU/Linux',
          hardware_platform: 'x86_64',
          processor: 'x86_64',
          release: 'centos',
          version: 7.0
        },
        opensuse: {
          kernel_name: 'Linux',
          kernel_version: '"#1 SMP Tue Jul 20 23:04:11 UTC 2021"',
          operating_system: 'GNU/Linux',
          hardware_platform: 'x86_64',
          processor: 'x86_64',
          release: 'opensuse-leap',
          version: 15.2
        }
      }

      defaults[name][property] if defaults[name].key?(property)
    end
  end
end
