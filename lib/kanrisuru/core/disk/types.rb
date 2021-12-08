
module Kanrisuru
  module Core
    module Disk
      DiskUsage = Struct.new(:fsize, :path)
      DiskFree = Struct.new(:file_system, :type, :total, :used, :capacity, :mount)
      LsblkDevice = Struct.new(
        :name, :maj_dev, :min_dev, :removable_device, :readonly_device, :owner, :group,
        :mode, :fsize, :type, :mount_point, :fs_type, :uuid, :children
      )

      BlkidDevice = Struct.new(
        :name, :label, :uuid, :type, :uuid_sub, :label_fatboot, :version, :usage,
        :part_uuid, :part_entry_scheme, :part_entry_uuid, :part_entry_type,
        :part_entry_number, :part_entry_offset, :part_entry_size, :part_entry_disk,
        :minimum_io_size, :physical_sector_size, :logical_sector_size
      )
    end
  end
end
