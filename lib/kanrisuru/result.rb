# frozen_string_literal: true

module Kanrisuru
  class Result
    include Enumerable

    attr_reader :error, :data, :command

    def initialize(command, &block)
      @command = command
      @data = nil

      @data = block.call(@command) if @command.success? && block_given?
      @error = @command.to_a if @command.failure?

      ## Define getter methods on result that maps to
      ## the same methods of a data struct.
      return unless @command.success? && Kanrisuru::Util.present?(@data) && @data.class.ancestors.include?(Struct)

      method_names = @data.members
      self.class.class_eval do
        method_names.each do |method_name|
          define_method method_name do
            @data[method_name]
          end
        end
      end
    end

    def [](prop)
      @data[prop]
    end

    def to_s
      @data.to_s
    end

    def to_a
      @data.instance_of?(Array) ? @data : [@data]
    end

    def to_i
      if @data.instance_of?(Integer)
        @data
      elsif @data.instance_of?(String)
        @data.to_i
      elsif @data.instance_of?(Array)
        @data.map(&:to_i)
      elsif @data.instance_of?(NilClass)
        nil
      else
        raise NoMethodError, "(undefined method `to_i' for Kanrisuru::Result)"
      end
    end

    def inspect
      if success?
        format('#<Kanrisuru::Result:0x%<object_id>s @status=%<status>s @data=%<data>s @command=%<command>s>',
               object_id: object_id, status: status, data: @data.inspect, command: command.prepared_command)
      else
        format('#<Kanrisuru::Result:0x%<object_id>s @status=%<status>s @error=%<error>s @command=%<command>s>',
               object_id: object_id, status: status, error: @error.inspect, command: command.prepared_command)
      end
    end

    def failure?
      @command.failure?
    end

    def success?
      @command.success?
    end

    def status
      @command.exit_status
    end

    def each(&block)
      @data.each { |item| block.call(item) } if @data.instance_of?(Array)
    end
  end
end
