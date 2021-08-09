# frozen_string_literal: true

require 'set'

module Kanrisuru
  module OsPackage
    module Define
      def self.extended(base)
        base.instance_variable_set(:@os_method_properties, {})
        base.instance_variable_set(:@os_methods, Set.new)
        base.instance_variable_set(:@os_method_cache, {})
      end

      def os_define(os_name, method_name, options = {})
        unique_method_name = options[:alias] || method_name

        @os_methods.add(method_name)

        if @os_method_properties.key?(unique_method_name)
          params = {
            os_name: os_name.to_s,
            method_name: method_name,
            options: options
          }

          @os_method_properties[unique_method_name].prepend(params)
        else
          @os_method_properties[unique_method_name] = [{
            os_name: os_name.to_s,
            method_name: method_name,
            options: options
          }]
        end
      end
    end

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

    module Include
      def os_include(mod, opts = {})
        os_method_properties = mod.instance_variable_get(:@os_method_properties)
        os_method_names = os_method_properties.keys

        ## Need to encapsulate any helper methods called in the module
        ## to bind to the host instance. This acts as a psudeo module include.
        os_methods        = mod.instance_variable_get(:@os_methods)

        public_methods    = mod.instance_methods(false) - os_methods.to_a
        private_methods   = mod.private_instance_methods(false)
        protected_methods = mod.protected_instance_methods(false)
        include_methods   = (public_methods + protected_methods + private_methods).flatten

        include_method_bindings = proc do
          define_method 'os_method_cache' do
            @os_method_cache ||= {}
          end

          private :os_method_cache

          include_methods.each do |method_name|
            define_method method_name do |*args, &block|
              unbound_method = mod.instance_method(method_name)
              bind_method(unbound_method, *args, &block)
            end
          end

          private_methods.each { |method_name| private(method_name) }
          protected_methods.each { |method_name| protected(method_name) }

          private
          if RUBY_VERSION < '2.7'
            define_method 'bind_method' do |unbound_method, *args, &block|
              unbound_method.bind(self).call(*args, &block)
            end
          else
            define_method 'bind_method' do |unbound_method, *args, &block|
              unbound_method.bind_call(self, *args, &block)
            end
          end
        end

        namespace          = opts[:namespace]
        namespace_class    = nil
        namespace_instance = nil

        if namespace
          ## Define the namespace as an eigen class instance within the host class.
          ## Namespaced instances will access core host methods
          ## with @host instance variable.

          ## Check to see if the namespace was defined. If so, additional methods will be appended to the
          ## existing namespace class definition, otherwise, a new namespace class and instance will be
          ## defined with the methods added.
          if Kanrisuru::Remote::Host.instance_variable_defined?("@#{namespace}")
            namespace_class = Kanrisuru::Remote::Host.const_get(Kanrisuru::Util.camelize(namespace))
            namespace_instance = instance_variable_get("@#{namespace}")
          else
            namespace_class    = Kanrisuru::Remote::Host.const_set(Kanrisuru::Util.camelize(namespace), Class.new)
            namespace_instance = Kanrisuru::Remote::Host.instance_variable_set("@#{namespace}", namespace_class.new)
            class_eval do
              define_method namespace do
                namespace_instance.instance_variable_set(:@host, self)
                namespace_instance
              end
            end
          end

          namespace_class.class_eval(&include_method_bindings)
        else
          class_eval(&include_method_bindings)
        end

        class_eval do
          os_method_names.each do |method_name|
            if namespace
              namespace_class.class_eval do
                define_method method_name do |*args, &block|
                  unbound_method = nil

                  if os_method_cache.key?("#{namespace}.#{method_name}")
                    unbound_method = os_method_cache["#{namespace}.#{method_name}"]
                  else
                    host = namespace_instance.instance_variable_get(:@host)

                    ## Find the correct method to resolve based on the OS for the remote host.
                    defined_method_name = host.resolve_os_method_name(os_method_properties, method_name)
                    unless defined_method_name
                      raise NoMethodError, "undefined method `#{method_name}' for #{self.class}"
                    end

                    ## Get reference to the unbound method defined in module
                    unbound_method = mod.instance_method(defined_method_name)
                    raise NoMethodError, "undefined method `#{method_name}' for #{self.class}" unless unbound_method

                    ## Cache the unbound method on this host instance for faster resolution on
                    ## the next invocation of this method
                    os_method_cache["#{namespace}.#{method_name}"] = unbound_method
                  end

                  ## Bind the method to host instance and
                  ## call it with args and block
                  bind_method(unbound_method, *args, &block)
                end
              end
            else
              define_method method_name do |*args, &block|
                unbound_method = nil

                if os_method_cache.key?(method_name)
                  unbound_method = os_method_cache[method_name]
                else
                  host = self

                  ## Find the correct method to resolve based on the OS for the remote host.
                  defined_method_name = host.resolve_os_method_name(os_method_properties, method_name)
                  raise NoMethodError, "undefined method `#{method_name}' for #{self.class}" unless defined_method_name

                  ## Get reference to the unbound method defined in module
                  unbound_method = mod.instance_method(defined_method_name)
                  raise NoMethodError, "undefined method `#{method_name}' for #{self.class}" unless unbound_method

                  ## Cache the unbound method on this host instance for faster resolution on
                  ## the next invocation of this method
                  os_method_cache[method_name] = unbound_method
                end

                ## Bind the method to host instance and
                ## call it with args and block
                bind_method(unbound_method, *args, &block)
              end
            end
          end

          def resolve_os_method_name(properties, method_name)
            kernel  = os.kernel.downcase
            release = os.release.downcase

            properties[method_name].each do |property|
              os_name = property[:os_name]
              strict = property[:options] ? property[:options][:strict] : false
              except = property[:options] ? property[:options][:except] : ''

              next if except && (except == release || except.include?(release))

              if release == os_name || kernel == os_name ||
                 (Kanrisuru::Util::OsFamily.family_include_distribution?(os_name, release) && !strict) ||
                 (Kanrisuru::Util::OsFamily.upstream_include_distribution?(os_name, release) && !strict)
                return property[:method_name]
              end
            end

            nil
          end
        end
      end
    end
  end
end
