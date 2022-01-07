# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Mount do
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

  it 'prepares mount command' do
    expect_command(host.mount, 'mount')
    expect_command(host.mount(bind_old: '/mnt/dira', bind_new: '/mnt/dirb'), 'mount --bind /mnt/dira /mnt/dirb')
    expect_command(host.mount(rbind_old: '/mnt/dira', rbind_new: '/mnt/dirb'), 'mount --rbind /mnt/dira /mnt/dirb')
    expect_command(host.mount(move_old: '/mnt/dira', move_new: '/mnt/dirb'), 'mount --move /mnt/dira /mnt/dirb')
    expect_command(host.mount(
                     label: 'cloudimg-rootfs',
                     uuid: '5fbaea960d09e2ad',
                     sloppy: true,
                     internal_only: true,
                     fake: true,
                     no_mtab: true,
                     no_canonicalize: true,
                     device: '/dev/vda9',
                     directory: '/mnt/dir1'
                   ), 'mount -L cloudimg-rootfs -U 5fbaea960d09e2ad -f -i -s --no-mtab --no-canonicalize /dev/vda9 /mnt/dir1')

    expect_command(host.mount(
                     fs_opts: { async: true, auto: true, group: true, relatime: true, owner: true },
                     device: '/dev/tty',
                     directory: '/mnt/dir2'
                   ), 'mount -o async,auto,group,relatime,owner /dev/tty /mnt/dir2')

    expect do
      host.mount(fs_opts: { value: true }, device: '/home/ubuntu/dir', directory: '/mnt/dir3')
    end.to raise_error(ArgumentError)

    expect_command(host.mount(
                     type: 'ext2',
                     device: '/dev/tty',
                     directory: '/mnt/dir2'
                   ), 'mount -t ext2 /dev/tty /mnt/dir2')

    expect_command(host.mount(
                     type: 'ext4',
                     fs_opts: { acl: true, journal: 'update', usrquota: true, async: true, owner: true, group: true },
                     device: '/dev/tty',
                     directory: '/mnt/dir2'
                   ), 'mount -t ext4 -o acl,journal=update,usrquota,async,owner,group /dev/tty /mnt/dir2')

    expect_command(host.mount(type: 'nontfs,xfs', all: true), 'mount -t nontfs,xfs -a')
    expect_command(host.mount(type: 'fat,xfs', all: true), 'mount -t fat,xfs -a')

    expect do
      host.mount(
        type: 'ext2',
        fs_opts: { acl: true, journal: 'update', usrquota: true, async: true, owner: true, group: true },
        device: '/dev/tty',
        directory: '/mnt/dir2'
      )
    end.to raise_error(ArgumentError)

    expect do
      host.mount(
        type: 'ext4',
        fs_opts: { acl: true, journal: true, usrquota: true, async: true, owner: true, group: true },
        device: '/dev/tty',
        directory: '/mnt/dir2'
      )
    end.to raise_error(ArgumentError)

    expect_command(host.mount(all: true, test_opts: { _netdev: true }), 'mount -a -O _netdev')
    expect_command(host.mount(all: true, test_opts: { async: true, blocksize: 512, uid: 0, gid: 0, dots: true }, type: 'fat'),
                   'mount -t fat -a -O async,blocksize=512,uid=0,gid=0,dots')

    expect_command(host.mount(
                     type: 'loop',
                     fs_opts: { loop: '/dev/loop3' },
                     device: '/mnt',
                     directory: '/tmp/fdimage'
                   ),
                   'mount -t loop -o loop=/dev/loop3 /mnt /tmp/fdimage')
  end

  it 'prepares umount command' do
    expect_command(host.umount, 'umount')
    expect_command(host.umount(recursive: true, all_targets: true), 'umount --all-targets --recursive')

    expect_command(host.umount(
                     fake: true,
                     no_canonicalize: true,
                     no_mtab: true,
                     fail_remount_readonly: true,
                     free_loopback: true,
                     lazy: true,
                     force: true,
                     device: '/dev/vda1'
                   ),
                   'umount --fake --no-canonicalize -n -r -d -l -f /dev/vda1')

    expect_command(host.umount(
                     all: true,
                     type: 'ext4,nofat'
                   ), 'umount -a -t ext4,nofat')

    expect_command(host.umount(
                     all: true,
                     type: 'ext4',
                     test_opts: { barrier: 1, nouid32: true }
                   ), 'umount -a -t ext4 -O barrier=1,nouid32')
  end
end
