module Kanrisuru::Core::System
  module Parser
    class W 
      def self.parse(command)
        result_string = command.raw_result.join
        rows = result_string.split("\n")

        rows.map do |row|
          values = *row.split(/\s+/, 8)
          Kanrisuru::Core::System::UserLoggedIn.new(
            values[0],
            values[1],
            IPAddr.new(values[2]),
            values[3],
            values[4],
            values[5].to_f,
            values[6].to_f,
            values[7]
          )
        end
      end
    end
  end
end