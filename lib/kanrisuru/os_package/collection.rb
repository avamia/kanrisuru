# frozen_string_literal: true

module Kanrisuru
  module OsPackage
    module Collection
      def os_collection(mod, opts = {})
        os_method_properties = mod.instance_variable_get(:@os_method_properties)
        os_method_names = os_method_properties.keys

        namespace          = opts[:namespace]
        namespace_instance = nil

        if namespace
          ## Define the namespace as an eigen class instance on the host.
          ## Namespaced instances will access core host methods
          ## with @host instance variable.

          if Kanrisuru::Remote::Cluster.instance_variable_defined?("@#{namespace}")
            namespace_class = Kanrisuru::Remote::Cluster.const_get(Kanrisuru::Util.camelize(namespace))
            namespace_instance = instance_variable_get("@#{namespace}")
          else
            namespace_class    = Kanrisuru::Remote::Cluster.const_set(Kanrisuru::Util.camelize(namespace), Class.new)
            namespace_instance = Kanrisuru::Remote::Cluster.instance_variable_set("@#{namespace}", namespace_class.new)

            class_eval do
              define_method namespace do
                namespace_instance.instance_variable_set(:@cluster, self)
                namespace_instance
              end
            end
          end

          namespace_class.class_eval do
            os_method_names.each do |method_name|
              define_method method_name do |*args, &block|
                cluster = namespace_instance.instance_variable_get(:@cluster)
                hosts = cluster.instance_variable_get(:@hosts)
                hosts.map do |host_addr, host|
                  { host: host_addr, result: host.send(namespace).send(method_name, *args, &block) }
                end
              end
            end
          end
        else
          class_eval do
            os_method_names.each do |method_name|
              define_method method_name do |*args, &block|
                @hosts.map do |host_addr, host|
                  { host: host_addr, result: host.send(method_name, *args, &block) }
                end
              end
            end
          end
        end
      end
    end
  end
end
