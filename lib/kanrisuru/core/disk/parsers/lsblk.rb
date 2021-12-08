module Kanrisuru::Core::Disk
  module Parser
    class Lsblk
      class << self
        def parse(command, version)
          if version >= 2.27
            result  = command.to_json
            devices = result['blockdevices']
            build_lsblk_devices_json(devices)
          else
            build_lsblk_devices_text(command.to_a)
          end
        end

        def build_lsblk_devices_text(lines)
          devices = []

          lines.each do |line|
            values = line.split

            current_device = Kanrisuru::Core::Disk::LsblkDevice.new

            values.each do |value|
              key, value = value.split('=')
              value = value.gsub(/"/, '')

              case key
              when 'NAME'
                current_device.name = value
              when 'FSTYPE'
                current_device.fs_type = value
              when 'MAJ:MIN'
                maj, min = value.split(':')
                current_device.maj_dev = maj ? maj.to_i : nil
                current_device.min_dev = min ? min.to_i : nil
              when 'MOUNTPOINT'
                current_device.mount_point = value
              when 'SIZE'
                current_device.fsize = value
              when 'UUID'
                current_device.uuid = value
              when 'RO'
                current_device.readonly_device = value
              when 'RM'
                current_device.removable_device = value
              when 'OWNER'
                current_device.owner = value
              when 'GROUP'
                current_device.group = value
              when 'MODE'
                current_device.mode = value
              when 'TYPE'
                current_device.type = value
              end
            end

            devices << current_device
          end

          devices
        end

        def build_lsblk_devices_json(devices)
          devices.map do |device|
            children = (build_lsblk_devices_json(device['children']) if device.key?('children'))

            maj_min = device['maj:min']

            Kanrisuru::Core::Disk::LsblkDevice.new(
              device['name'],
              maj_min ? maj_min.split(':')[0].to_i : nil,
              maj_min ? maj_min.split(':')[1].to_i : nil,
              device['rm'],
              device['ro'],
              device['owner'],
              device['group'],
              device['mode'],
              device['size'],
              device['type'],
              device['mountpoint'],
              device['fstype'],
              device['uuid'],
              children
            )
          end
        end
      end
    end
  end
end
