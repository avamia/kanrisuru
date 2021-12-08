# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      module Parser
        class Search < Base
          def self.parse(command)
            lines = command.to_a
            result = []

            lines.each do |line|
              line = line.gsub(/\s{2}/, '')
              values = line.split(' : ')
              next if values.length != 2

              full_name = values[0]
              name, architecture = full_name.split('.')
              summary = values[1]

              result << Kanrisuru::Core::Yum::PackageSearchResult.new(name, architecture, summary)
            end

            result
          end
        end
      end
    end
  end
end
