# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Disk do
  TestHosts.each_os do |os_name|
    context "with #{os_name}" do
      let(:host_json) { TestHosts.host(os_name) }
      let(:host) do
        Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )
      end

      after do
        host.disconnect
      end

      it 'searches detail on block devices' do
        host.su('root')
        result = host.blkid
        expect(result.success?).to eq(true)

        device = result[0]
        expect(device).to respond_to(
          :name, :label, :type, :uuid,
          :label_fatboot, :part_uuid, :uuid_sub
        )

        result = host.blkid(uuid: device.uuid)
        expect(result.success?).to eq(true)
        expect(result.data).to eq(device.name)

        result = host.blkid(device: device.name)
        # puts device.name
        # puts result.inspect
        expect(result.success?).to eq(true)
        expect(result.data[0]).to respond_to(
          :name, :label, :uuid, :type, :uuid_sub, :label_fatboot, :version, :usage,
          :part_uuid, :part_entry_scheme, :part_entry_uuid, :part_entry_type,
          :part_entry_number, :part_entry_offset, :part_entry_size, :part_entry_disk,
          :minimum_io_size, :physical_sector_size, :logical_sector_size
        )
      end

      it 'gets details on block devices' do
        result = host.lsblk
        expect(result.data).to be_instance_of(Array)

        device = result[0]

        expect(device).to respond_to(
          :name, :maj_dev, :min_dev,
          :removable_device, :readonly_device,
          :owner, :group, :mode,
          :fsize, :type, :mount_point,
          :fs_type, :uuid, :children
        )
      end

      it 'gets summarize disk usage' do
        result = host.du(path: "#{host_json['home']}/.bashrc", summarize: true)
        expect(result).to be_success
        expect(result[0].path).to eq("#{host_json['home']}/.bashrc")
      end

      it 'gets all disk usage' do
        result = host.du(path: host_json['home'])
        expect(result).to be_success
        expect(result.data.length).to be >= 2
      end

      it 'gets summarized disk usage root user' do
        host.su('root')
        result = host.du(path: '/etc', summarize: true)
        expect(result).to be_success
        expect(result[0].path).to eq('/etc')
      end

      it 'gets disk free for system' do
        expect(host.df.data).to be_instance_of(Array)
        expect(host.df(inodes: true).data).to be_instance_of(Array)
      end

      it 'gets disk usage for path' do
        result = host.df(path: '/')
        expect(result.data).to be_instance_of(Array)
        expect(result[0].mount).to eq('/')
      end
    end
  end
end
