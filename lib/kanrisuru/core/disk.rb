# frozen_string_literal: true

require 'json'

module Kanrisuru
  module Core
    module Disk
      extend OsPackage::Define

      os_define :linux, :df
      os_define :linux, :du
      os_define :linux, :blkid
      os_define :linux, :lsblk

      DiskUsage = Struct.new(:fsize, :path)
      DiskFree = Struct.new(:file_system, :type, :total, :used, :capacity, :mount)
      LsblkDevice = Struct.new(
        :name, :maj_dev, :min_dev, :removable_device, :readonly_device, :owner, :group,
        :mode, :fsize, :type, :mount_point, :fs_type, :uuid, :children
      )

      BlkidDevice = Struct.new(
        :name, :label, :uuid, :type, :uuid_sub, :label_fatboot, :version, :usage,
        :part_uuid, :part_entry_scheme, :part_entry_uuid, :part_entry_type,
        :part_entry_number, :part_entry_offset, :part_entry_size, :part_entry_disk
      )

      def du(opts = {})
        path    = opts[:path]
        convert = opts[:convert]

        command = Kanrisuru::Command.new('du')
        command.append_arg('-s', path)
        command | "awk '{print $1, $2}'"

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          string = cmd.to_s
          rows = string.split("\n")

          rows.map do |row|
            values = row.split
            size = convert ? Kanrisuru::Util::Bits.convert_bytes(values[0], :byte, convert) : values[0]

            DiskUsage.new(size, values[1])
          end
        end
      end

      def df(opts = {})
        path   = opts[:path]
        inodes = opts[:inodes]

        command = Kanrisuru::Command.new('df')

        command.append_flag('-PT')
        command.append_flag('-i', inodes)

        command << path if Kanrisuru::Util.present?(path)
        command | "awk '{print $1, $2, $3, $5, $6, $7}'"

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          items = []
          rows = cmd.to_a
          rows.each.with_index do |row, index|
            next if index.zero?

            values = row.split

            items << DiskFree.new(
              values[0],
              values[1],
              values[2].to_i,
              values[3].to_i,
              values[4].to_i,
              values[5]
            )
          end
          items
        end
      end

      def blkid(opts = {})
        label = opts[:label]
        uuid  = opts[:uuid]
        device = opts[:device]

        mode = ''
        command = Kanrisuru::Command.new('blkid')

        if Kanrisuru::Util.present?(label) || Kanrisuru::Util.present?(uuid)
          mode = 'search'
          command.append_arg('-L', opts[:label])
          command.append_arg('-U', opts[:uuid])
        elsif Kanrisuru::Util.present?(device)
          mode = 'device'
          command.append_arg('-po', 'export')
          command << device
        else
          mode = 'list'
          command.append_arg('-o', 'export')
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          case mode
          when 'search'
            cmd.to_s
          when 'device'
            lines = cmd.to_a

            ## Only gets 1 device
            devices = blkid_devices(lines)
            devices[0]
          else
            lines = cmd.to_a
            blkid_devices(lines)
          end
        end
      end

      def lsblk(opts = {})
        all    = opts[:all]
        nodeps = opts[:nodeps]
        paths  = opts[:paths]

        command = Kanrisuru::Command.new('lsblk')

        version = lsblk_version

        ## lsblk after version 2.26 handles json parsing.
        ## TODO: parse nested children for earlier version of lsblk
        if version >= 2.27
          command.append_flag('--json') if version >= 2.27
        else
          command.append_flag('-i')
          command.append_flag('-P')
          command.append_flag('--noheadings')
        end

        command.append_flag('-a', all)
        command.append_flag('-p', paths)
        command.append_flag('-p', nodeps)

        command.append_arg('-o', 'NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          if version >= 2.27
            result  = cmd.to_json
            devices = result['blockdevices']
            build_lsblk_devices_json(devices)
          else
            build_lsblk_devices_text(cmd.to_a)
          end
        end
      end

      private

      def blkid_devices(lines)
        devices = []
        current_device = nil

        lines.each do |line|
          value = line.split('=')[1]

          if line =~ /^DEVNAME=/
            current_device = BlkidDevice.new(value)
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

      def lsblk_version
        command = Kanrisuru::Command.new('lsblk --version')
        execute(command)

        version = 0.00
        regex = Regexp.new(/\d+(?:[,.]\d+)?/)

        raise 'lsblk command not found' if command.failure?

        version = command.to_s.scan(regex)[0].to_f unless regex.match(command.to_s).nil?

        version
      end

      def build_lsblk_devices_text(lines)
        devices = []

        lines.each do |line|
          values = line.split

          current_device = LsblkDevice.new

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
              current_device.maj_dev = maj
              current_device.min_dev = min
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

          LsblkDevice.new(
            device['name'],
            maj_min ? maj_min.split(':')[0] : nil,
            maj_min ? maj_min.split(':')[1] : nil,
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
