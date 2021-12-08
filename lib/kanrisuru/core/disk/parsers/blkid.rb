# frozen_string_literal: true

module Kanrisuru
  module Core
    module Disk
      module Parser
        class Blkid
          class << self
            def parse(command, mode)
              return command.to_s if mode == 'search'

              lines = command.to_a

              devices = []
              current_device = nil

              lines.each do |line|
                value = line.split('=')[1]

                if line =~ /^DEVNAME=/
                  current_device = Kanrisuru::Core::Disk::BlkidDevice.new(value)
                elsif line =~ /^UUID=/
                  current_device.uuid = value
                elsif line =~ /^LABEL=/
                  current_device.label = value
                elsif line =~ /^TYPE=/
                  current_device.type = value
                elsif line =~ /^LABEL_FATBOOT=/
                  current_device.label_fatboot = value
                elsif line =~ /^PARTUUID=/
                  current_device.part_uuid = value
                elsif line =~ /^UUID_SUB=/
                  current_device.uuid_sub = value
                elsif line =~ /^USAGE=/
                  current_device.usage = value
                elsif line =~ /^VERSION=/
                  current_device.version = value.to_f
                elsif line =~ /^MINIMUM_IO_SIZE=/
                  current_device.minimum_io_size = value.to_i
                elsif line =~ /^PHYSICAL_SECTOR_SIZE=/
                  current_device.physical_sector_size = value.to_i
                elsif line =~ /^LOGICAL_SECTOR_SIZE=/
                  current_device.logical_sector_size = value.to_i
                elsif line =~ /^PART_ENTRY_SCHEME=/
                  current_device.part_entry_scheme = value
                elsif line =~ /^PART_ENTRY_UUID=/
                  current_device.part_entry_uuid = value
                elsif line =~ /^PART_ENTRY_DISK=/
                  current_device.part_entry_disk = value
                elsif line =~ /^PART_ENTRY_NUMBER=/
                  current_device.part_entry_number = value.to_i
                elsif line =~ /^PART_ENTRY_OFFSET=/
                  current_device.part_entry_offset = value.to_i
                elsif line =~ /^PART_ENTRY_SIZE=/
                  current_device.part_entry_size = value.to_i
                elsif line =~ /^PART_ENTRY_TYPE=/
                  current_device.part_entry_type = value
                elsif Kanrisuru::Util.blank?(line)
                  devices << current_device
                  current_device = nil
                end
              end

              devices << current_device if Kanrisuru::Util.present?(current_device)
              devices
            end
          end
        end
      end
    end
  end
end
