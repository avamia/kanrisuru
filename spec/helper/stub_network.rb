# frozen_string_literal: true

class StubNetwork
  class << self
    def stub!
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
          def initialize(host)
            @host = host

            @kernel_name       = 'Linux'
            @kernel_version    = '#91-Ubuntu SMP Thu Jul 15 19:09:17 UTC 2021'
            @operating_system  = 'GNU/Linux'
            @hardware_platform = 'x86_64'
            @processor         = 'x86_64'
            @release           = 'ubuntu'
            @version           = 20.0
          end
        end
      end

      unless Kanrisuru::Result.instance_methods(false).include?(:initialize_alias)
        Kanrisuru::Result.class_eval do
          alias_method :initialize_alias, :initialize 
          def initialize(command)
            @command = command
            @data = nil

            @error = @command.to_a if @command.failure?
          end
        end
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

  end
end
