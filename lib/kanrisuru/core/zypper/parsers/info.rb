# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      module Parser
        class Info < Base
          def self.parse(command)
            lines = command.to_a

            rows = []
            current_row = nil
            description = ''
            skip_description = false

            lines.each do |line|
              case line
              when /^Repository/
                repository = extract_single_zypper_line(line)
                next if repository == ''

                unless current_row.nil?
                  skip_description = false
                  current_row.description = description.strip
                  description = ''
                  rows << current_row
                end

                current_row = Kanrisuru::Core::Zypper::PackageDetail.new
                current_row.repository = repository
              when /^Name/
                current_row.package = extract_single_zypper_line(line)
              when /^Version/
                current_row.version = extract_single_zypper_line(line)
              when /^Arch/
                current_row.architecture = extract_single_zypper_line(line)
              when /^Vendor/
                current_row.vendor = extract_single_zypper_line(line)
              when /^Support Level/
                current_row.support_level = extract_single_zypper_line(line)
              when /^Installed Size/
                size = Kanrisuru::Util::Bits.normalize_size(extract_single_zypper_line(line))
                current_row.install_size = size
              when /^Installed/
                value = extract_single_zypper_line(line)
                current_row.installed = value == 'Yes'
              when /^Status/
                current_row.status = extract_single_zypper_line(line)
              when /^Source package/
                current_row.source_package = extract_single_zypper_line(line)
              when /^Summary/
                current_row.summary = extract_single_zypper_line(line)
              when /^Description/
                description = extract_single_zypper_line(line)
              when /^Builds binary package/, /^Contents/
                skip_description = true
              else
                next if line == ''
                next if line.include?('Information for package')
                next if line.include?('---------------------------')

                description += " #{line.strip}" unless skip_description
              end
            end

            if current_row
              current_row.description = description.strip
              rows << current_row
            end

            rows
          end
        end
      end
    end
  end
end
