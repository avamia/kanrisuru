# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Disk do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'responds to methods' do
    expect(host).to respond_to(:df)
    expect(host).to respond_to(:du)
    expect(host).to respond_to(:blkid)
    expect(host).to respond_to(:lsblk)
  end

  it 'responds to disk fields' do
    expect(Kanrisuru::Core::Disk::DiskUsage.new).to respond_to(:fsize, :path)
    expect(Kanrisuru::Core::Disk::DiskFree.new).to respond_to(
      :file_system, :type, :total, :used, :capacity, :mount
    )
    expect(Kanrisuru::Core::Disk::LsblkDevice.new).to respond_to(
      :name, :maj_dev, :min_dev, :removable_device, :readonly_device, :owner, :group,
      :mode, :fsize, :type, :mount_point, :fs_type, :uuid, :children
    )
    expect(Kanrisuru::Core::Disk::BlkidDevice.new).to respond_to(
      :name, :label, :uuid, :type, :uuid_sub, :label_fatboot, :version, :usage,
      :part_uuid, :part_entry_scheme, :part_entry_uuid, :part_entry_type,
      :part_entry_number, :part_entry_offset, :part_entry_size, :part_entry_disk,
      :minimum_io_size, :physical_sector_size, :logical_sector_size
    )
  end
end
