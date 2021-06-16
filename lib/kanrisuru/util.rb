# frozen_string_literal: true

require_relative 'util/bits'
require_relative 'util/os_family'
require_relative 'util/fs_mount_opts'
require_relative 'util/signal'

module Kanrisuru
  class Util
    def self.blank?(value)
      value.respond_to?(:empty?) ? value.empty? : !value
    end

    def self.present?(value)
      !Kanrisuru::Util.blank?(value)
    end

    def self.array_join_string(arg)
      arg.instance_of?(Array) ? arg.join(',') : arg
    end

    def self.string_join_array(arg)
      array = arg.instance_of?(String) ? [arg] : arg
      array.join(',')
    end

    def self.numeric?(value)
      !Float(value).nil?
    rescue StandardError
      false
    end

    def self.camelize(string)
      string = string.to_s
      string = string.sub(/^[a-z\d]*/, &:capitalize)
      string.gsub!(%r{(?:_|(/))([a-z\d]*)}i) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
      string
    end
  end
end
