module Kanrisuru
  module Core
    module Dmi
      def dmi(opts = {})
        command = Kanrisuru::Command.new('dmidecode')
        dmi_type_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Kanrisuru::Core::Dmi::Parser.parse(cmd) 
        end
      end

      private
      
      def dmi_type_opts(command, opts)
        return unless Kanrisuru::Util.present?(opts[:types])

        types = opts[:types]
        types = [types] if types.instance_of?(String)

        types.each do |type|
          type = Kanrisuru::Core::Dmi::Parser.parse_dmi_type(type)
          command.append_arg('--type', type)
        end
      end
    end
  end
end
 