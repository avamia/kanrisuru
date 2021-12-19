# frozen_string_literal: true

module Kanrisuru
  class Command
    attr_reader :exit_status, :raw_result, :program
    attr_writer :remote_user, :remote_shell, :remote_path, :remote_env

    def initialize(command)
      @valid_exit_codes = [0]
      @raw_command = command
      @raw_result = []
    end

    def success?
      @valid_exit_codes.include?(@exit_status)
    end

    def failure?
      !success?
    end

    def to_i
      to_a.join.to_i
    end

    def to_f
      to_a.join.to_f
    end

    def to_s
      to_a.join(' ')
    end

    def to_json(*_args)
      JSON.parse(to_s)
    end

    def to_a
      string = @raw_result.join
      string.lines.map(&:strip)
    end

    def prepared_command
      if !@remote_user.nil? && !@remote_shell.nil?
        evaluate = ''
        evaluate += if Kanrisuru::Util.present?(@remote_path)
                      "cd #{@remote_path} && #{@raw_command}"
                    else
                      @raw_command.to_s
                    end

        env = @remote_env && !@remote_env.empty? ? "#{@remote_env} " : ''
        "#{env}sudo -u #{@remote_user} #{@remote_shell} -c \"#{evaluate}\""
      else
        @raw_command
      end
    end

    def raw_command
      @raw_command.to_s
    end

    def handle_status(status)
      @exit_status = status
    end

    def handle_data(data)
      @raw_result.push(data)
    end

    def handle_signal(signal)
      @signal = signal
    end

    def +(other)
      append_value(other)
    end

    def <<(value)
      append_value(value)
    end

    def |(other)
      pipe(other)
    end

    def pipe(value)
      append_value("| #{value}")
    end

    def append_array(value, separator = ' ')
      return unless Kanrisuru::Util.present?(value)

      append_value(Kanrisuru::Util.array_join_string(value, separator))
    end

    def append_value(value)
      @raw_command = "#{@raw_command} #{value}"
    end

    def append_arg(arg, string)
      @raw_command = Kanrisuru::Util.present?(string) ? "#{@raw_command} #{arg} #{string}" : @raw_command
    end

    def append_flag(arg, boolean = 'true')
      @raw_command = Kanrisuru::Util.present?(boolean) ? "#{@raw_command} #{arg}" : @raw_command
    end

    def append_flag_no(arg, boolean = 'true')
      return if boolean.nil?

      if boolean
        append_flag(arg, true)
      else
        append_flag("no#{arg}", true)
      end
    end

    def append_valid_exit_code(code)
      @valid_exit_codes << code if code.instance_of?(Integer)
      @valid_exit_codes.concat(code) if code.instance_of?(Array)
    end
  end
end
