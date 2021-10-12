# frozen_string_literal: true

class StubNetwork
  class << self

    def stub!
      ## Stub out the execute_with_retries method to 
      ## test functionality of host commands 
      Kanrisuru::Remote::Host.class_eval do
        private

        def execute_with_retries(command)
          command.handle_status(0) 
          command.handle_data(nil)

          command
        end
      end

      Kanrisuru::Remote::Os.class_eval do
        def initialize(host)
          @host = host

          @kernel_name       = 'Linux'
          @kernel_version    = '#91-Ubuntu SMP Thu Jul 15 19:09:17 UTC 2021'
          @operating_system  = 'GNU/Linux'
          @hardware_platform = "x86_64"
          @processor         = "x86_64"
          @release           = "ubuntu"
          @version           = 20.0
        end
      end

      Kanrisuru::Result.class_eval do
        def initialize(command, &block)
          @command = command
          @data = nil

          @error = @command.to_a if @command.failure?
        end
      end
    end 

  end
end
