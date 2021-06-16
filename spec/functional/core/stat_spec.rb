# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Stat do
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

      it 'checks file type correctly' do
        expect(host.dir?('/')).to eq(true)
        expect(host.file?('/etc/hosts')).to eq(true)

        case os_name
        when 'sles'
          expect(host.block_device?('/dev/xvda')).to eq(true)
        else
          expect(host.block_device?('/dev/vda')).to eq(true)
        end

        expect(host.char_device?('/dev/tty')).to eq(true)
        expect(host.symlink?('/etc/mtab')).to eq(true)
        expect(host.inode?('/proc/uptime')).to eq(true)
      end

      it 'gets file stat' do
        result = host.stat(host_json['home'])

        expect(result.mode).to be_instance_of(Kanrisuru::Mode)
        expect(result.mode.directory?).to eq(true)

        case os_name
        when 'centos', 'rhel', 'fedora'
          expect(result.mode.numeric).to eq('700')
          expect(result.mode.to_i).to eq(0o700)

          expect(result.mode.group.read?).to eq(false)
          expect(result.mode.group.write?).to eq(false)
          expect(result.mode.group.execute?).to eq(false)

          expect(result.mode.other.read?).to eq(false)
          expect(result.mode.other.write?).to eq(false)
          expect(result.mode.other.execute?).to eq(false)

          expect(result.mode.owner.read?).to eq(true)
          expect(result.mode.owner.write?).to eq(true)
          expect(result.mode.owner.execute?).to eq(true)

          expect(result.mode.symbolic).to eq('drwx------')
        else
          expect(result.mode.numeric).to eq('755')
          expect(result.mode.to_i).to eq(0o755)

          expect(result.mode.group.read?).to eq(true)
          expect(result.mode.group.write?).to eq(false)
          expect(result.mode.group.execute?).to eq(true)

          expect(result.mode.other.read?).to eq(true)
          expect(result.mode.other.write?).to eq(false)
          expect(result.mode.other.execute?).to eq(true)

          expect(result.mode.owner.read?).to eq(true)
          expect(result.mode.owner.write?).to eq(true)
          expect(result.mode.owner.execute?).to eq(true)

          expect(result.mode.symbolic).to eq('drwxr-xr-x')
        end

        expect(result.file_type).to eq('directory')

        case os_name
        when 'opensuse', 'sles'
          expect(result.gid).to eq(100)
          expect(result.group).to eq('users')
        else
          expect(result.gid).to eq(1000)
          expect(result.group).to eq(host_json['username'])
        end

        expect(result.uid).to eq(1000)
        expect(result.user).to eq(host_json['username'])

        expect(result.fsize).to be >= 0
      end
    end
  end
end
