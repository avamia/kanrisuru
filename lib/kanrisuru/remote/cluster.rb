# frozen_string_literal: true
require 'thread'

module Kanrisuru
  module Remote
    class Cluster
      extend OsPackage::Collection
      include Enumerable

      attr_accessor :parallel, :concurrency

      def initialize(*hosts)
        @parallel = false 
        @concurrency = local_concurrency

        @hosts = {}
        hosts.each do |host_opts|
          add_host(host_opts)
        end
      end

      def hosts
        @hosts.values
      end

      def [](hostname)
        @hosts[hostname]
      end

      def <<(host_opts)
        add_host(host_opts)
      end

      def delete(host)
        remove_host(host)
      end

      def execute(command)
        map { |host| host.execute(create_command(command)) }
      end

      def execute_shell(command)
        map { |host| host.execute_shell(create_command(command)) }
      end

      def hostname
        map { |host| host.send(:hostname) }
      end

      def ping?
        map { |host| host.send(:ping?) }
      end

      def su(user)
        each { |host| host.su(user) }
      end

      def chdir(path = '~')
        cd(path)
      end

      def cd(path = '~')
        each { |host| host.cd(path) }
      end

      def disconnect
        each { |host| host.disconnect }
      end

      def map(&block)
        parallel? ? each_parallel(preserve: true, &block) : each_sequential(preserve: true, &block)
      end

      def each(&block)
        parallel? ? each_parallel(preserve: false, &block) : each_sequential(preserve: false, &block)
      end

      def parallel?
        @parallel 
      end

      def sequential?
        !parallel?
      end

      private

      def each_sequential(opts = {}, &block)
        results = @hosts.map do |host_addr, host| 
          { host: host_addr, result: block.call(host) }
        end

        opts[:preserve] ? results : self
      end

      def each_parallel(opts = {}, &block)
        queue = Queue.new.tap do |q|
          @hosts.each { |_, host| q << host }
        end

        threads = []
        results = []
        mutex = Mutex.new

        ## No need to spawn more threads then number of hosts in cluster
        concurrency = queue.length < @concurrency ? queue.length : @concurrency 
        concurrency.times do
          threads << Thread.new do
            loop do
              host = queue.pop(true) rescue Thread.exit

              begin
                result = block.call(host)
                mutex.synchronize { results.push({ host: host.host, result: result }) }
              rescue Exception => exception
                mutex.synchronize { results.push({ host: host.host, result: exception }) }
              end
            end
          end
        end

        threads.each(&:join) 

        opts[:preserve] ? results : self
      end

      def create_command(command)
        case command
        when String
          Kanrisuru::Command.new(command)
        when Kanrisuru::Command
          command.clone
        else
          raise ArgumentError, 'Invalid command type'
        end
      end

      def remove_host(host)
        if host.instance_of?(Kanrisuru::Remote::Host)
          removed = false

          if @hosts.key?(host.host)
            removed = true
            @hosts.delete(host.host)
          end

          removed
        elsif host.instance_of?(String)
          removed = false

          if @hosts.key?(host)
            removed = true
            @hosts.delete(host)
          end

          removed
        else
          raise ArgumentError, 'Invalid host type'
        end
      end

      def add_host(host_opts)
        case host_opts
        when Hash
          @hosts[host_opts[:host]] = Kanrisuru::Remote::Host.new(host_opts)
        when Kanrisuru::Remote::Host
          @hosts[host_opts.host] = host_opts
        when Kanrisuru::Remote::Cluster
          host_opts.send(:each_sequential) { |host| @hosts[host.host] = host }
        else
          raise ArgumentError, 'Invalid host option'
        end
      end

      def local_concurrency
        ProcessorCount.physical_processor_count
      end

    end
  end
end
