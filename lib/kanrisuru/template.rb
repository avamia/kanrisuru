# frozen_string_literal: true

require 'erb'

module Kanrisuru
  class Template
    attr_writer :trim_mode

    def initialize(path, args = {})
      @path = path
      @trim_mode = '-'

      args.each do |variable_name, value|
        instance_variable_set("@#{variable_name}", value)
      end
    end

    def render
      erb.result(binding)
    end

    def read
      StringIO.new(render)
    end

    private

    def erb
      ERB.new(File.read(@path), trim_mode: @trim_mode)
    end
  end
end
