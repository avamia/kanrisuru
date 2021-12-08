module Kanrisuru
  module Core
    module System
      def who(opts = {})
        w(opts)
      end
      
      def w(opts = {})
        users = opts[:users]
        command = Kanrisuru::Command.new('w -hi')

        command << users if Kanrisuru::Util.present?(users)

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::W.parse(cmd)
        end
      end
    end
  end
end
