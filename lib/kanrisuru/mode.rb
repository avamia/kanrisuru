# frozen_string_literal: true

require_relative 'mode/permission'

module Kanrisuru
  class Mode
    attr_reader :owner, :group, :other

    def initialize(mode)
      if mode.instance_of?(Integer)
        init_mode(mode.to_s(8))
      elsif mode.instance_of?(String)
        init_mode(mode)
      else
        raise 'Invalid mode type'
      end
    end

    def directory?
      @directory == 'd'
    end

    def symbolic
      @directory + @owner.symbolic + @group.symbolic + @other.symbolic
    end

    def symbolic=(string)
      raise ArgumentErorr, 'Invalid symbolic type' if string.class != String

      if string.length == 10 && !string.include?(',')
        modes = string[1..-1]

        @owner.symbolic = modes[0..2]
        @group.symbolic = modes[3..5]
        @other.symbolic = modes[6..8]
      else
        operations = string.split(',')
        operations.each do |operation|
          flags = operation.split(/[=+-]/)

          commands = flags[0] == '' ? 'a' : flags[0]
          fields = flags[1]

          commands = commands.chars

          commands.each do |command|
            case command
            when 'a'
              apply_operation(operation, fields, @owner)
              apply_operation(operation, fields, @group)
              apply_operation(operation, fields, @other)
            when 'u'
              apply_operation(operation, fields, @owner)
            when 'g'
              apply_operation(operation, fields, @group)
            when 'o'
              apply_operation(operation, fields, @other)
            end
          end
        end
      end
    end

    def numeric
      @owner.numeric + @group.numeric + @other.numeric
    end

    def numeric=(numeric)
      string =
        if numeric.instance_of?(Integer)
          numeric.to_s(8)
        else
          numeric
        end

      tokens = string.chars

      @owner.numeric = tokens[0]
      @group.numeric = tokens[1]
      @other.numeric = tokens[2]
    end

    def inspect
      format('#<Kanrisuru::Mode:0x%<object_id>s @numeric=%<numeric>s @symbolic=%<symbolic>s>',
             object_id: object_id, numeric: numeric, symbolic: symbolic)
    end

    def to_s
      symbolic
    end

    def to_i
      numeric.to_i(8)
    end

    private

    def apply_operation(operation, fields, permission)
      if operation.include?('=')
        remaining_fields = 'rwx'

        fields.chars.each do |field|
          apply_field_to_permission(field, permission, true)

          ## remove any field that shouldn't be set to false
          remaining_fields = remaining_fields.gsub(field, '')
        end

        ## Apply false to any remaining fields
        apply_field_to_permission(remaining_fields, permission, false)
      elsif operation.include?('-')
        apply_field_to_permission(fields, permission, false)
      elsif operation.include?('+')
        apply_field_to_permission(fields, permission, true)
      end
    end

    def apply_field_to_permission(fields, permission, boolean)
      permission.read = boolean if fields.include?('r')
      permission.write = boolean if fields.include?('w')
      permission.execute = boolean if fields.include?('x')
    end

    def init_mode(string)
      string = parse_acl(string)

      if string.length == 3
        @directory = '-'
        tokens = string.chars

        @owner = Kanrisuru::Mode::Permission.new(tokens[0], numeric_to_symbolic(tokens[0].to_i))
        @group = Kanrisuru::Mode::Permission.new(tokens[1], numeric_to_symbolic(tokens[1].to_i))
        @other = Kanrisuru::Mode::Permission.new(tokens[2], numeric_to_symbolic(tokens[2].to_i))
      elsif string.length == 10 && !string.include?(',')
        @directory = string[0]
        modes = string[1..-1]

        @owner = Kanrisuru::Mode::Permission.new(symbolic_to_numeric(modes[0..2]), modes[0..2])
        @group = Kanrisuru::Mode::Permission.new(symbolic_to_numeric(modes[3..5]), modes[3..5])
        @other = Kanrisuru::Mode::Permission.new(symbolic_to_numeric(modes[6..8]), modes[6..8])
      else
        raise ArgumentError, "Invalid format for mode #{string}"
      end
    end

    def parse_acl(string)
      @acl = string[-1] == '.' ? 'selinux' : 'general'
      string.gsub(/[.+]/, '')
    end

    def symbolic_to_numeric(ref)
      conversions = {
        '---' => 0,
        '--x' => 1,
        '-w-' => 2,
        '-wx' => 3,
        'r--' => 4,
        'r-x' => 5,
        'rw-' => 6,
        'rwx' => 7
      }

      conversions[ref]
    end

    def numeric_to_symbolic(int)
      conversions = {
        0 => '---',
        1 => '--x',
        2 => '-w-',
        3 => '-wx',
        4 => 'r--',
        5 => 'r-x',
        6 => 'rw-',
        7 => 'rwx'
      }

      conversions[int]
    end
  end
end
