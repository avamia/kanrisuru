# frozen_string_literal: true

require 'ostruct'

module Kanrisuru
  module Core
    module System
      module Parser
        class Sysctl
          class << self
            def parse(command)
              result = {}

              lines = command.to_a
              lines.each do |line|
                next if line.include?('permission denied on key')

                keys, value = parse_line(line)
                next if Kanrisuru::Util.blank?(value)

                hash = build_nested_hash(keys, value)
                result = merge_recursively(result, hash)
              end

              build_struct(result)
            end

            def build_struct(hash)
              struct = Struct.new(*hash.keys).new

              hash.each_key do |key|
                struct[key] = hash[key].is_a?(Hash) ? build_struct(hash[key]) : hash[key]
              end

              struct
            end

            def merge_recursively(h1, h2)
              h1.merge(h2) do |_k, v1, v2|
                if v1.is_a?(Hash) && v2.is_a?(Hash)
                  merge_recursively(v1, v2)
                else
                  [v1, v2].flatten
                end
              end
            end

            def build_nested_hash(array, value)
              array.reverse.inject(value) { |assigned_value, key| { key => assigned_value } }
            end

            def parse_line(line)
              string, value = line.split(' =')
              return if Kanrisuru::Util.blank?(value)

              string = string.strip
              value = value.strip

              if Kanrisuru::Util.numeric?(value)
                value = value.to_i
              elsif /\t+/.match(value)
                ## Split tab delimited strings
                value = value.split(/\t/)
              end

              [string.split('.').map(&:to_sym), value]
            end
          end
        end
      end
    end
  end
end
