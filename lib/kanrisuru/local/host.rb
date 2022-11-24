# frozen_string_literal: true

require 'open3'

module Kanrisuru
  module Local
    class Host
      extend OsPackage::Include
  
      def initialize(opts = {})
        @username = opts[:username]
        @current_dir = ''
      end

      def local_user
        @local_user ||= @username
      end

      def os
        @os ||= init_os
      end

      def ping?
        check = Net::Ping::External.new(@host)
        check.ping?
      end

      def execute_shell(command)
        command = Kanrisuru::Command.new(command) if command.instance_of?(String)

        command.remote_user = remote_user
        command.remote_shell = @shell
        command.remote_path = @current_dir
        command.remote_env = env.to_s

        execute_with_retries(command)
      end

      def su(user)
        @local_user = user
      end

      def execute(command)
        command = Kanrisuru::Command.new(command) if command.instance_of?(String)

        execute_with_retries(command)
      end

      private

      def init_os
        Os.new(self)
      end

      def execute_with_retries(command)
        raise 'Invalid command type' unless command.instance_of?(Kanrisuru::Command)

        retry_attempts = 3

        Kanrisuru.logger.debug { "kanrisuru:~$ #{command.prepared_command}" }

        begin
          Open3.popen3(command.prepared_command) do |stdin, stdout, stderr, wait_thr|
            pid = wait_thr.pid
            exit_status = wait_thr.value

            stdout_data = stdout.read
            stderr_data = stderr.read

            command.handle_status(exit_status)

            Kanrisuru.logger.debug { stdout_data.strip }
            command.handle_data(stdout_data)
          end
        rescue StandardError => e
          if retry_attempts > 1
            retry_attempts -= 1
            retry
          else
            raise e.class
          end
        end
      end

    end
  end
end
