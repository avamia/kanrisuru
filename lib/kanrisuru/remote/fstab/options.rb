# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Fstab
      class Options
        def initialize(type, opts)
          @type = type
          @valid = false

          if opts.instance_of?(String)
            @opts = parse_opts(opts)
          elsif opts.instance_of?(Hash)
            @opts = opts.transform_keys(&:to_s)
          else
            raise ArgumentError, 'Invalid option type'
          end

          validate_opts!
        end

        def inspect
          format('<Kanrisuru::Remote::Fstab::Options:0x%<object_id>s @opts=%<opts>s @type=%<type>s>',
                 object_id: object_id, opts: @opts, type: @type)
        end

        def [](option)
          @opts[option]
        end

        def []=(option, value)
          option = option.to_s

          unless Kanrisuru::Remote::Fstab::Options.option_exists?(option, @type)
            raise ArgumentError,
                  "Invalid option: #{option} for #{@type} file system."
          end

          unless Kanrisuru::Remote::Fstab::Options.valid_option?(option, value, @type)
            raise ArgumentError,
                  "Invalid option value: #{value} for #{option} on #{@type} file system."
          end

          @opts[option] = value
        end

        def to_s
          string = ''
          opts_length = @opts.length

          @opts.each_with_index do |(key, value), index|
            append_comma = true

            if value == true
              string += key.to_s
            elsif value.instance_of?(String) || value.instance_of?(Integer) || value.instance_of?(Float)
              string += "#{key}=#{value}"
            else
              append_comma = false
            end

            string += ',' if append_comma && index < opts_length - 1
          end

          string
        end

        def to_h
          @opts
        end

        def self.option_exists?(value, type = nil)
          value = value.to_sym
          type = type ? type.to_sym : nil

          common = Kanrisuru::Util::FsMountOpts[:common]
          fs_opts = Kanrisuru::Util::FsMountOpts[type]

          common.key?(value) ||
            fs_opts&.key?(value)
        end

        def self.valid_option?(value, field, type = nil)
          value = value.to_sym
          type = type ? type.to_sym : nil

          common = Kanrisuru::Util::FsMountOpts[:common]
          fs_opts = Kanrisuru::Util::FsMountOpts[type]

          if common.key?(value)
            case common[value]
            when 'boolean'
              [true, false].include?(field)
            when 'value'
              field.instance_of?(String) || field.instance_of?(Float) || field.instance_of?(Integer)
            else
              false
            end
          elsif fs_opts&.key?(value)
            case fs_opts[value]
            when 'boolean'
              [true, false].include?(field)
            when 'value'
              field.instance_of?(String) || field.instance_of?(Float) || field.instance_of?(Integer)
            else
              false
            end
          else
            raise ArgumentError, 'Invalid option'
          end
        end

        private

        def validate_opts!
          @opts.each do |key, value|
            unless Kanrisuru::Remote::Fstab::Options.valid_option?(key, value, @type)
              raise ArgumentError, "Invalid option: #{key} for #{@type}"
            end
          end

          @valid = true
        end

        def parse_opts(string)
          opts = {}

          options = string.split(',')
          options.each do |option|
            if option.include?('=')
              opt, value = option.split('=')
              opts[opt] = value
            else
              opts[option] = true
            end
          end

          opts
        end
      end
    end
  end
end
