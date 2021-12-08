# frozen_string_literal: true

module Kanrisuru
  module Core
    module Dmi
      def dmi(opts = {})
        command = Kanrisuru::Command.new('dmidecode')
        dmi_type_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Dmi.parse(cmd)
        end
      end

      private

      def dmi_type_opts(command, opts)
        return unless Kanrisuru::Util.present?(opts[:types])

        types = opts[:types]
        types = [types] if types.instance_of?(String)

        types.each do |type|
          type = get_dmi_type(type)
          command.append_arg('--type', type)
        end
      end

      def get_dmi_type(type)
        raise ArgumentError, 'Invalid DMI type' unless Kanrisuru::Util::DmiType.valid?(type)

        if type.instance_of?(Integer)
          type
        else
          Kanrisuru::Util::DmiType[type]
        end
      end
    end
  end
end
