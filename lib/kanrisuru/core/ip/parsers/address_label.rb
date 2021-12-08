module Kanrisuru::Core::IP
  module Parser
    class AddressLabel < Base
      class << self
        def parse(command, action, version)
          if %w[show list].include?(action)
            if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
              begin
                ip_address_label_result_json(command.to_json)
              rescue JSON::ParserError
                ip_address_label_result_parse(command.to_a)
              end
            else
              ip_address_label_result_parse(command.to_a)
            end
          end
        end
      end
    end
  end
end
