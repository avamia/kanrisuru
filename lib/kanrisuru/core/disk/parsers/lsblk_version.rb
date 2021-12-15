# frozen_string_literal: true

module Kanrisuru
  module Core
    module Disk
      module Parser
        class LsblkVersion
          def self.parse(command)
            version = 0.00
            regex = Regexp.new(/\d+(?:[,.]\d+)?/)

            raise 'lsblk command not found' if command.failure?

            version = command.to_s.scan(regex)[0].to_f unless regex.match(command.to_s).nil?
            version
          end
        end
      end
    end
  end
end
