# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Cluster
      extend OsPackage::Collection
      include Enumerable

      def initialize(hosts)
        @hosts = {}
        hosts.each do |host_opts|
          add_host(host_opts)
        end
      end

      def [](hostname)
        @hosts[hostname]
      end

      def <<(host_opts)
        add_host(host_opts)
      end

      def execute(command)
        @hosts.map do |host_addr, host|
          ## Need to evaluate each host independently for the command.
          cmd = Kanrisuru::Command.new(command)

          { host: host_addr, result: host.execute(cmd) }
        end
      end

      def execute_shell(command)
        @hosts.map do |host_addr, host|
          ## Need to evaluate each host independently for the command.
          cmd = Kanrisuru::Command.new(command)

          { host: host_addr, result: host.execute_shell(cmd) }
        end
      end

      def each(&block)
        @hosts.each { |_host_addr, host| block.call(host) }
      end

      def hostname
        map_host_results(:hostname)
      end

      def ping?
        map_host_results(:ping?)
      end

      def su(user)
        @hosts.each do |_host_addr, host|
          host.su(user)
        end
      end

      def chdir(path = '~')
        cd(path)
      end

      def cd(path = '~')
        @hosts.each do |_host_addr, host|
          host.cd(path)
        end
      end

      def disconnect
        @hosts.each do |_host_addr, host|
          host.disconnect
        end
      end

      private

      def map_host_results(action)
        @hosts.map do |host_addr, host|
          { host: host_addr, result: host.send(action) }
        end
      end

      def add_host(host_opts)
        if host_opts.instance_of?(Hash)
          @hosts[host_opts[:host]] = Kanrisuru::Remote::Host.new(host_opts)
        elsif host_opts.instance_of?(Kanrisuru::Remote::Host)
          @hosts[host_opts.host] = host_opts
        else
          raise 'Not a valid host option'
        end
      end
    end
  end
end
