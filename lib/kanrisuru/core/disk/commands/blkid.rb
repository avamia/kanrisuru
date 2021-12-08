
module Kanrisuru
  module Core
    module Disk
      def blkid(opts = {})
        label = opts[:label]
        uuid  = opts[:uuid]
        device = opts[:device]

        mode = ''
        command = Kanrisuru::Command.new('blkid')

        if Kanrisuru::Util.present?(label) || Kanrisuru::Util.present?(uuid)
          mode = 'search'
          command.append_arg('-L', opts[:label])
          command.append_arg('-U', opts[:uuid])
        elsif Kanrisuru::Util.present?(device)
          mode = 'device'
          command.append_arg('-pio', 'export')
          command << device
        else
          mode = 'list'
          command.append_arg('-o', 'export')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Blkid.parse(cmd, mode)
        end
      end
    end
  end
end
