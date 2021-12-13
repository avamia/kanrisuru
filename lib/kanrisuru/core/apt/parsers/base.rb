# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      module Parser
        class Base
          class << self
            def extract_single_line(line)
              line.split(': ')[1]
            end

            def parse_comma_values(string)
              string.split(', ')
            end

            def parse_apt_sources(string)
              url, dist, architecture, = string.split
              Kanrisuru::Core::Apt::Source.new(url, dist, architecture)
            end

            def parse_apt_line(line)
              values = line.split('/')
              return if values.length < 2

              package = values[0]

              values = values[1].split
              suites = values[0].split(',')
              version = values[1]
              architecture = values[2]

              installed = false
              upgradeable = false
              automatic = false

              if values.length > 3
                installed = values[3].include?('installed')
                upgradeable = values[3].include?('upgradeable')
                automatic = values[3].include?('automatic')
              end

              Kanrisuru::Core::Apt::PackageOverview.new(package, version, suites, architecture, installed, upgradeable,
                                                        automatic)
            end
          end
        end
      end
    end
  end
end
