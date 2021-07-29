# frozen_string_literal: true

class TestHosts
  class << self
    def each_os(opts = {}, &block)
      %w[debian ubuntu fedora centos rhel opensuse sles].each do |os_name|
        next unless test?(os_name)
        next if opts[:only] && !only?(opts, os_name)

        block.call(os_name)
      end
    end

    def host(name)
      hosts(name)
    end

    def only?(opts, name)
      ((opts[:only].instance_of?(Array) && opts[:only].include?(name)) ||
        (opts[:only].instance_of?(String) && opts[:only] == name))
    end

    def test?(name)
      return false if host(name).nil?

      if testable_hosts.nil? && excludable_hosts.nil?
        true
      elsif testable_hosts.nil? && !excludable_hosts.nil?
        hosts_exclude_array = excludable_hosts.split(',')

        !hosts_exclude_array.include?(name)
      elsif !testable_hosts.nil? && excludable_hosts.nil?
        hosts_include_array = testable_hosts.split(',')

        hosts_include_array.include?(name)
      else
        hosts_include_array = testable_hosts.split(',')
        hosts_exclude_array = excludable_hosts.split(',')

        hosts_include_array.include?(name) && !hosts_exclude_array.include?(name)
      end
    end

    def hosts(name)
      @hosts ||= begin
        result = {}

        hosts_list.each do |host_item|
          result[host_item['name']] = host_item
        end

        result
      end

      @hosts[name]
    end

    def hosts_list
      json_config_path = File.join('spec', 'hosts.json')
      hosts_data = File.open(json_config_path).read
      JSON.parse(hosts_data)
    end

    private

    def excludable_hosts
      ENV['EXCLUDE'] || ENV['IGNORE']
    end

    def testable_hosts
      ENV['HOSTS']
    end
  end
end
