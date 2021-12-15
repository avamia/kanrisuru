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

  it 'prepares blkid command' do
    expect_command(host.blkid, 'blkid -o export')
    expect_command(host.blkid(device: '/dev/vda1'), 'blkid -pio export /dev/vda1')
    expect_command(host.blkid(label: 'UEFI'), 'blkid -L UEFI')
    expect_command(host.blkid(uuid: '26F2-56F9'), 'blkid -U 26F2-56F9')
    expect_command(host.blkid(label: 'UEFI', uuid: '26F2-56F9'), 'blkid -L UEFI -U 26F2-56F9')
  end

  it 'prepares df command' do
    expect_command(host.df, "df -PT | awk '{print $1, $2, $3, $5, $6, $7}'")
    expect_command(host.df(inodes: true, path: '/dev/vda1'),
                   "df -PT -i /dev/vda1 | awk '{print $1, $2, $3, $5, $6, $7}'")
  end

  it 'prepares du command' do
    expect_command(host.du, "du | awk '{print \\$1, \\$2}'")
    expect_command(host.du(summarize: true, path: '/etc'), "du -s /etc | awk '{print \\$1, \\$2}'")
  end

  context 'with json support' do
    before(:all) do
      StubNetwork.stub_command!(:lsblk_version) do
        Kanrisuru::Core::Disk::LSBK_VERSION
      end
    end

    after(:all) do
      StubNetwork.unstub_command!(:lsblk_version)
    end

    it 'prepares lsblk command' do
      expect_command(host.lsblk, 'lsblk --json -o NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
      expect_command(host.lsblk(all: true, paths: true, nodeps: true),
                     'lsblk --json -a -p -d -o NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
    end
  end

  context 'without json support' do
    before(:all) do
      StubNetwork.stub_command!(:lsblk_version) do
        Kanrisuru::Core::Disk::LSBK_VERSION - 0.1
      end
    end

    after(:all) do
      StubNetwork.unstub_command!(:lsblk_version)
    end

    it 'prepares lsblk command' do
      expect_command(host.lsblk,
                     'lsblk -i -P --noheadings -o NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
      expect_command(host.lsblk(all: true, paths: true, nodeps: true),
                     'lsblk -i -P --noheadings -a -p -d -o NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
    end
  end
end
