module Kanrisuru
  module Core
    module System
      def cpu_info(spec)
        Kanrisuru.logger.info do
          'DEPRECATION WARNING: cpu_info will be removed in the upcoming major release. Use lscpu instead.'
        end

        name =
          case spec
          when 'sockets'
            '^Socket'
          when 'cores_per_socket'
            '^Core'
          when 'threads'
            '^Thread'
          when 'cores'
            '^CPU('
          else
            return
          end

        command = Kanrisuru::Command.new("lscpu | grep -i '#{name}' | awk '{print $NF}'")
        execute(command)

        Kanrisuru::Result.new(command, &:to_i)
      end
    end
  end
end
