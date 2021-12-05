# frozen_string_literal: true

module Kanrisuru
  module OsPackage
    module Define
      def self.extended(base)
        base.instance_variable_set(:@os_method_properties, {})
        base.instance_variable_set(:@os_methods, Set.new)
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
  end
end
