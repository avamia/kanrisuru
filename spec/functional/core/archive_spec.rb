# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Archive do
  before(:all) do
    StubNetwork.stub!
    StubNetwork.stub_command!(:realpath) do |_args|
      Kanrisuru::Core::Path::FilePath.new(directory)
    end
  end

  after(:all) do
    StubNetwork.unstub_command!(:realpath)
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  let(:directory) { '/home/ubuntu/dir' }

  it 'prepares tar list command' do
    %w[list t].each do |action_variant|
      expect_command(host.tar(action_variant, 'file.txt'),
                     'tar --restrict -f file.txt -t')

      expect_command(host.tar(action_variant, '~/file.txt',
                              compress: 'bzip2',
                              directory: directory,
                              occurrence: 1,
                              label: true,
                              multi_volume: true),
                     'tar --restrict -C /home/ubuntu/dir -f ~/file.txt -j -t --occurrence 1 --label --multi-volume')
    end
  end

  it 'prepares tar extract command' do
    %w[extract get x].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive.tar'),
                     'tar --restrict -f archive.tar -x')

      expect_command(host.tar(action_variant, 'archive.tar',
                              compress: 'xz',
                              directory: directory,
                              occurrence: 2,
                              no_same_owner: true,
                              no_same_permissions: true,
                              no_selinux: true,
                              no_xattrs: true,
                              multi_volume: true,
                              label: true,
                              skip_old_files: true,
                              overwrite: true,
                              overwrite_dir: true,
                              unlink_first: true,
                              recursive_unlink: true,
                              paths: 'file.txt'),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -J -x --occurrence 2 --no-same-owner --no-same-permissions --no-selinux --no-xattrs --multi-volume --label --skip-old-files --overwrite --overwrite-dir --unlink-first --recursive-unlink file.txt')

      expect_command(host.tar(action_variant, 'archive.tar',
                              preserve_permissions: true,
                              same_owners: true,
                              one_file_system: true,
                              keep_old_files: true,
                              paths: ['file1.txt', 'file2.txt']),
                     'tar --restrict -f archive.tar -x --preserve-permissions --same-owner --one-file-system --keep-old-files file1.txt file2.txt')
    end
  end

  it 'prepares tar create command' do
    %w[create c].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive.lzma', compress: 'lzma'),
                     'tar --restrict -f archive.lzma --lzma -c')
      expect_command(host.tar(action_variant, 'archive.gz'), 'tar --restrict -f archive.gz -c')

      expect_command(host.tar(action_variant, 'archive.gz',
                              directory: directory,
                              compress: 'gzip',
                              exclude: 'file2.txt',
                              paths: 'file1.txt'),
                     'tar --restrict -C /home/ubuntu/dir -f archive.gz -z -c --exclude=file2.txt file1.txt')

      expect_command(host.tar(action_variant, 'archive.gz',
                              compress: 'gzip',
                              exclude: ['file2.txt', 'file4.txt'],
                              paths: ['file1.txt', 'file3.txt']),
                     'tar --restrict -f archive.gz -z -c --exclude=file2.txt --exclude=file4.txt file1.txt file3.txt')
    end
  end

  it 'prepares tar append command' do
    %w[append r].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive.tar'), 'tar --restrict -f archive.tar -r')

      expect_command(host.tar(action_variant, 'archive.tar',
                              directory: directory,
                              paths: 'main.conf'),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -r main.conf')

      expect_command(host.tar(action_variant, 'archive.tar',
                              paths: ['main.conf', 'main2.conf']),
                     'tar --restrict -f archive.tar -r main.conf main2.conf')
    end
  end

  it 'prepares tar concat command' do
    %w[catenate concat A].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive.tar'), 'tar --restrict -f archive.tar -A')
      expect_command(host.tar(action_variant, 'archive.tar',
                              directory: directory,
                              paths: 'archive2.tar'),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -A archive2.tar')

      expect_command(host.tar(action_variant, 'archive.tar',
                              directory: directory,
                              paths: ['archive2.tar', 'archive3.tar']),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -A archive2.tar archive3.tar')
    end
  end

  it 'prepares tar update command' do
    %w[update u].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive',
                              paths: 'file1.txt'),
                     'tar --restrict -f archive -u file1.txt')

      expect_command(host.tar(action_variant, 'archive',
                              directory: directory,
                              paths: ['file1.txt', 'file2.txt']),
                     'tar --restrict -C /home/ubuntu/dir -f archive -u file1.txt file2.txt')
    end
  end

  it 'prepares tar diff command' do
    %w[diff compare d].each do |action_variant|
      expect_command(host.tar(action_variant, 'archive.tar', directory: directory),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -d')

      expect_command(host.tar(action_variant, 'archive.tar',
                              directory: directory,
                              occurrence: 4),
                     'tar --restrict -C /home/ubuntu/dir -f archive.tar -d --occurrence 4')
    end
  end

  it 'prepares tar delete command' do
    expect_command(host.tar('delete', 'archive.tar', paths: 'file1.txt'),
                   'tar --restrict -f archive.tar --delete file1.txt')
    expect_command(host.tar('delete', 'archive.tar',
                            paths: ['file1.txt', 'file2.txt'],
                            occurrence: 3),
                   'tar --restrict -f archive.tar --delete --occurrence 3 file1.txt file2.txt')
  end

  it 'prepares invalid tar command' do
    expect do
      host.tar('abc', 'file1.txt')
    end.to raise_error(ArgumentError)

    expect do
      host.tar('create', 'archive.tar', compress: 'xip')
    end.to raise_error(ArgumentError)
  end
end
