# frozen_string_literal: true

require 'open3'

module Kanrisuru
  module Local 
    class Host
      extend OsPackage::Include

      attr_reader :username 

      def initialize(opts = {})
        @opts = opts

        @username = opts[:username]
        @login_user = @username

        @shell    = opts[:shell] || '/bin/bash'

        @current_dir = ''
      end

      def local_user
        @local_user ||= @username
      end

      def hostname
        @hostname ||= init_hostname
      end

      def os
        @os ||= init_os
      end

      def env
        @env ||= init_env
      end

      def template(path, args = {})
        Kanrisuru::Template.new(path, args)
      end

      def fstab(file = '/etc/fstab')
        @fstab ||= init_fstab(file)
      end

      def chdir(path = '~')
        cd(path)
      end

      def cd(path = '~')
        @current_dir = pwd.path if Kanrisuru::Util.blank?(@current_dir)

        @current_dir =
          if path == '~'
            realpath('~').path
          elsif path[0] == '.' || path[0] != '/'
            ## Use strip to preserve symlink directories
            realpath("#{@current_dir}/#{path}", strip: true).path
          else
            ## Use strip to preserve symlink directories
            realpath(path, strip: true).path
          end
      end

      def cpu
        @cpu ||= init_cpu
      end

      def memory
        @memory ||= init_memory
      end

      def su(user)
        @remote_user = user
      end

      def file(path)
        Kanrisuru::Remote::File.new(path, self)
      end

      def ssh
        @ssh ||= init_ssh
      end

      def proxy
        @proxy ||= init_proxy
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

      def execute(command)
        command = Kanrisuru::Command.new(command) if command.instance_of?(String)
        execute_with_retries(command)
      end

      def disconnect
        ssh.close
        proxy&.close(ssh.transport.port)
      end

      private

      def execute_with_retries(command)
        raise 'Invalid command type' unless command.instance_of?(Kanrisuru::Command)

        retry_attempts = 3

        Kanrisuru.logger.debug { "kanrisuru:~$ #{command.prepared_command}" }

        begin
          data, status = Open3.capture3(command.prepared_command)

          Kanrisuru.logger.debug { data.strip }

          command.handle_status(status.to_i)
          command.handle_data(data)

          command
        rescue StandardError => e 
          if retry_attempts > 1
            retry_attempts -= 1
            retry
          else
            raise e.class
          end
        end
      end

      def init_hostname
        command = Kanrisuru::Command.new('hostname')
        execute(command)

        command.success? ? command.to_s : nil
      end

      def init_env
        Env.new
      end

      def init_fstab(file)
        Fstab.new(self, file)
      end

      def init_memory
        Memory.new(self)
      end

      def init_os
        Kanrisuru::Os.new(self)
      end

      def init_cpu
        Cpu.new(self)
      end
    end
  end
end
