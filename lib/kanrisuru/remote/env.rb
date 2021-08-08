# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Env
      def initialize
        @env = {}
      end

      def to_h
        @env
      end

      def clear
        @env = {}
      end

      def to_s
        string = ''
        @env.each.with_index do |(key, value), index|
          string += "export #{key}=#{value};"
          string += ' ' if index < @env.length - 1
        end

        string
      end

      def [](key)
        @env[key.to_s.upcase]
      end

      def []=(key, value)
        @env[key.to_s.upcase] = value
      end
    end
  end
end
