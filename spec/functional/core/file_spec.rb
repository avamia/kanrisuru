# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::File do
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

  it 'prepares chmod command' do
    expect_command(host.chmod('/home/ubuntu/file1.txt', '-rwxrwxrwx'), 'chmod 777 /home/ubuntu/file1.txt')
    expect_command(host.chmod('/home/ubuntu/dir', 'drwxrwxrwx', recursive: true), 'chmod 777 /home/ubuntu/dir -R')
    expect_command(host.chmod('/home/ubuntu/dir', '600', recursive: true), 'chmod 600 /home/ubuntu/dir -R')
    expect_command(host.chmod('/home/ubuntu/file2.conf', Kanrisuru::Mode.new('-rwxr--r--')),
                   'chmod 744 /home/ubuntu/file2.conf')
    expect_command(host.chmod('/home/ubuntu/file2.conf', 'g+x'), 'chmod g+x /home/ubuntu/file2.conf')
  end

  context 'with user and group stubs' do
    before(:all) do
      StubNetwork.stub_command!(:get_uid) do
        1000
      end

      StubNetwork.stub_command!(:get_gid) do
        1000
      end
    end

    after(:all) do
      StubNetwork.unstub_command!(:get_uid)
      StubNetwork.unstub_command!(:get_gid)
    end

    it 'prepares chown command' do
      expect_command(host.chown('/home/ubuntu/file1.text', owner: 'ubuntu', group: 'ubuntu'),
                     'chown 1000:1000 /home/ubuntu/file1.text')
      expect_command(host.chown('/home/ubuntu/file1.text', owner: 'ubuntu'), 'chown 1000 /home/ubuntu/file1.text')
      expect_command(host.chown('/home/ubuntu/file1.text', group: 'ubuntu'), 'chown :1000 /home/ubuntu/file1.text')
      expect(host.chown('/home/ubuntu/file1.txt')).to be_falsey
      expect_command(host.chown('/home/ubuntu/dir', owner: 1000, group: 1000, recursive: true),
                     'chown 1000:1000 -R /home/ubuntu/dir')
    end
  end

  it 'prepares copy command' do
    expect_command(host.copy('~/fileA', '~/fileB'), 'cp ~/fileA ~/fileB')
    expect_command(host.copy('~/fileA', '~/fileB'), 'cp ~/fileA ~/fileB')
    expect_command(host.copy('~/dir1', '~/dir2', {
                               recursive: true,
                               one_file_system: true,
                               update: true,
                               no_clobber: true,
                               strip_trailing_slashes: true
                             }), 'cp -R -x -u -n --strip-trailing-slashes ~/dir1 ~/dir2')

    expect_command(host.copy('~/file1', '~/file1.copy', {
                               backup: true
                             }), 'cp -b ~/file1 ~/file1.copy')

    expect_command(host.copy('~/file1', '~/file1.copy', {
                               backup: 'simple'
                             }), 'cp --backup=simple ~/file1 ~/file1.copy')

    expect do
      host.cp('~/file1', '~/file1.copy', { backup: 'forever' })
    end.to raise_error(ArgumentError)

    expect_command(host.cp('~/file1', '~/file2', { preserve: true }), 'cp -p ~/file1 ~/file2')
    expect_command(host.cp('~/file1', '~/file2', { preserve: 'mode' }), 'cp --preserve=mode ~/file1 ~/file2')
    expect_command(host.cp('~/file1', '~/file2', { preserve: %w[timestamps links] }),
                   'cp --preserve=timestamps,links ~/file1 ~/file2')
    expect_command(host.copy('~/fileA', '~/fileB', { no_target_directory: true }), 'cp -T ~/fileA ~/fileB')
    expect_command(host.copy('~/fileA', '~/dirB', { target_directory: true }), 'cp -t ~/dirB ~/fileA')
  end

  context 'with dir stubs' do
    before(:all) do
      StubNetwork.stub_command!(:dir?, { return_value: true })
    end

    after(:all) do
      StubNetwork.unstub_command!(:dir?)
    end

    it 'prepares link command' do
      expect(host.ln('/home/ubuntu/dir', '/home/ubuntu/file1')).to be_falsey
    end
  end

  context 'with dir stubs false' do
    before(:all) do
      StubNetwork.stub_command!(:dir?, { return_value: false })
    end

    after(:all) do
      StubNetwork.unstub_command!(:dir?)
    end

    it 'prepares link command' do
      expect_command(host.link('/home/ubuntu/file1', '/home/ubuntu/dir/file1'),
                     'ln /home/ubuntu/file1 /home/ubuntu/dir/file1')

      expect_command(host.ln('/home/ubuntu/file1', '/home/ubuntu/dir/file1', { force: true }),
                     'ln /home/ubuntu/file1 /home/ubuntu/dir/file1 -f')
    end
  end

  it 'prepares mkdir command' do
    expect_command(host.mkdir('/home/ubuntu/dir1'), 'mkdir /home/ubuntu/dir1')
    expect_command(host.mkdir(['~/dir1', '~/dir2', '~/dir3'], { silent: true }), 'mkdir ~/dir1 ~/dir2 ~/dir3 -p')
    expect_command(host.mkdir('dir', { mode: '644' }), 'mkdir dir -m 644')
    expect_command(host.mkdir(['dir2', '/etc/ddir'], { mode: Kanrisuru::Mode.new('dr--r--r--') }),
                   'mkdir dir2 /etc/ddir -m 444')
    expect_command(host.mkdir(['dir2', '/etc/ddir'], { mode: 'o+w' }), 'mkdir dir2 /etc/ddir -m o+w')
  end

  it 'prepares move command' do
    expect_command(host.mv('~/fileA', '~/fileB'), 'mv ~/fileA ~/fileB')
    expect_command(host.move('~/fileA', '~/fileB', { force: true }), 'mv -f ~/fileA ~/fileB')
    expect_command(host.mv('~/fileA', '~/fileB', { no_clobber: true }), 'mv -n ~/fileA ~/fileB')
    expect_command(host.mv('~/fileA', '~/fileB', { strip_trailing_slashes: true, force: true }),
                   'mv --strip-trailing-slashes -f ~/fileA ~/fileB')
    expect_command(host.mv('~/fileA', '~/fileB', { backup: true }), 'mv -b ~/fileA ~/fileB')
    expect_command(host.mv('~/fileA', '~/fileB', { backup: 'numbered' }), 'mv --backup=numbered ~/fileA ~/fileB')

    expect do
      host.mv('~/fileA', '~/fileB', { backup: 'null' })
    end.to raise_error(ArgumentError)

    expect_command(host.mv('~/fileA', '~/fileB', { no_target_directory: true }), 'mv -T ~/fileA ~/fileB')
    expect_command(host.mv(['~/fileA', '~/fileB'], '~/dir1', { target_directory: true }),
                   'mv -t ~/dir1 ~/fileA ~/fileB')
    expect_command(host.mv(['~/fileA', '~/fileB'], '~/dir1'), 'mv ~/fileA ~/fileB ~/dir1')
  end

  context 'with realpath non root' do
    before(:all) do
      StubNetwork.stub_command!(:realpath) do
        Kanrisuru::Core::Path::FilePath.new('/home/ubuntu/fileA')
      end
    end

    after(:all) do
      StubNetwork.unstub_command!(:realpath)
    end

    it 'prepares rm command' do
      expect_command(host.rm('~/fileA'), 'rm ~/fileA --preserve-root')
      expect_command(host.rm('~/fileA', { force: true }), 'rm ~/fileA --preserve-root -f')
      expect_command(host.rm('~/dirA', { force: true, recursive: true }), 'rm ~/dirA --preserve-root -f -r')
      expect_command(host.rm(['~/dirA', '~/dirB'], { force: true, recursive: true }),
                     'rm ~/dirA ~/dirB --preserve-root -f -r')
    end

    it 'prepares rmdir command' do
      expect_command(host.rmdir('~/dir1'), 'rmdir ~/dir1')
      expect_command(host.rmdir(['~/dir1', '~/dir2'], { silent: true, parents: true }),
                     'rmdir ~/dir1 ~/dir2 --ignore-fail-on-non-empty --parents')
    end
  end

  context 'with realpath root' do
    before(:all) do
      StubNetwork.stub_command!(:realpath) do
        Kanrisuru::Core::Path::FilePath.new('/')
      end
    end

    after(:all) do
      StubNetwork.unstub_command!(:realpath)
    end

    it 'prepares rm command' do
      expect do
        host.rm('/', { force: true, recursive: true })
      end.to raise_error(ArgumentError)

      expect do
        host.rm('/etc/..', { force: true, recursive: true })
      end.to raise_error(ArgumentError)
    end

    it 'prepares rmdir command' do
      expect do
        host.rmdir('/etc/..', { silent: true })
      end.to raise_error(ArgumentError)
    end
  end

  context 'with stub' do
    before(:all) do
      StubNetwork.stub_command!(:realpath) do |cmd|
        result = cmd[0].gsub('~', '/home/ubuntu')
        Kanrisuru::Core::Path::FilePath.new(result)
      end

      StubNetwork.stub_command!(:inode?, { return_value: true })
      StubNetwork.stub_command!(:symlink?, { return_value: false })
    end

    after(:all) do
      StubNetwork.unstub_command!(:realpath)
      StubNetwork.unstub_command!(:inode?)
      StubNetwork.unstub_command!(:symlink?)
    end

    it 'prepares symlink command' do
      StubNetwork.stub_command!(:dir?, { return_value: false })
      expect_command(host.ln_s('~/fileA', '/etc/fileA'), 'ln -s /home/ubuntu/fileA /etc/fileA')
      expect_command(host.ln_s('~/fileA', '/etc/fileA', { force: true }), 'ln -s /home/ubuntu/fileA /etc/fileA -f')
      StubNetwork.unstub_command!(:dir?)

      StubNetwork.stub_command!(:dir?, { return_value: true })
      expect_command(host.symlink('~/fileA', '~/dirA', { force: true }),
                     'ln -s /home/ubuntu/fileA /home/ubuntu/dirA -f')
      StubNetwork.unstub_command!(:dir?)
    end
  end

  context 'with broken stub' do
    it 'prepares symlink command' do
      StubNetwork.stub_command!(:inode?, { return_value: true })
      StubNetwork.stub_command!(:realpath) do |_cmd|
        Kanrisuru::Core::Path::FilePath.new('/')
      end

      expect do
        host.symlink('/', '~/fileB')
      end.to raise_error(ArgumentError)

      expect do
        host.symlink('/var/..', '~/fileB')
      end.to raise_error(ArgumentError)

      StubNetwork.unstub_command!(:inode?)
      StubNetwork.unstub_command!(:realpath)

      StubNetwork.stub_command!(:inode?, { return_value: false })
      StubNetwork.stub_command!(:realpath) do |_cmd|
        Kanrisuru::Core::Path::FilePath.new('')
      end

      expect do
        host.symlink('', '~/fileB')
      end.to raise_error(ArgumentError)

      expect do
        host.symlink('/home', '~/fileB')
      end.to raise_error(ArgumentError)

      StubNetwork.unstub_command!(:inode?)
      StubNetwork.unstub_command!(:realpath)
    end
  end

  it 'prepares touch command' do
    expect_command(host.touch('file.conf'), 'touch file.conf')
    expect_command(host.touch(['file1.conf', 'file2.conf']), 'touch file1.conf file2.conf')
    expect_command(host.touch('file.conf', { atime: true, mtime: true, nofiles: true }), 'touch file.conf -a -m -c')
    expect_command(host.touch('file.conf', { date: '2021-12-31' }), 'touch file.conf -d 2021-12-31')
    expect_command(host.touch('file.conf', { reference: '~/otherfile.conf' }), 'touch file.conf -r ~/otherfile.conf')
  end

  it 'prepares unlink command' do
    expect_command(host.unlink('/home/ubuntu/file1'), 'unlink /home/ubuntu/file1')
  end

  it 'prepares wc command' do
    expect_command(host.wc('/var/log/syslog'), 'wc /var/log/syslog')
  end
end
