# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'path' do |os_name, host_json, _spec_dir|
  context "with #{os_name}" do
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

    it 'lists files and directories' do
      result = host.ls(all: true)
      expect(result.data).to be_instance_of(Array)

      dir = result.find { |file| file.path == '.' }
      expect(dir.path).to eq('.')

      result = host.ls(path: host_json['home'], id: true, all: true)
      expect(result.data).to be_instance_of(Array)

      file = result.find { |f| f.path == '.bashrc' }
      expect(file.owner).to eq(1000)

      case os_name
      when 'opensuse', 'sles'
        expect(file.group).to eq(100)
      else
        expect(file.group).to eq(1000)
      end
    end

    it 'gets whoami' do
      expect(host.whoami.user).to eq(host_json['username'])
    end

    it 'gets pwd' do
      expect(host.pwd.path).to eq(host_json['home'])
    end

    it 'uses which to get path for bash' do
      result = host.which('bash', all: true)
      paths = result.map(&:path)

      case os_name
      when 'ubuntu'
        if host.os.version <= 18.04
          expect(paths).to include('/bin/bash')
        else
          expect(paths).to include('/usr/bin/bash', '/bin/bash')
        end
      when 'opensuse'
        ## Ignore for local testing
      when 'sles'
        expect(paths).to include('/bin/bash')
      else
        expect(paths).to include('/usr/bin/bash', '/bin/bash')
      end
    end

    it 'gets realpath for dir' do
      case os_name
      when 'sles'
        expect(host.realpath('/var/run').path).to eq('/run')
      when 'rhel'
        expect(host.realpath('/bin').path).to eq('/usr/bin')
      else
        expect(host.realpath('/etc/os-release').path).to eq('/usr/lib/os-release')
      end
    end

    it 'gets full path for dir with readlink' do
      case os_name
      when 'sles'
        expect(host.readlink('/var/run', canonicalize: true).path).to eq('/run')
      when 'rhel'
        expect(host.readlink('/bin', canonicalize: true).path).to eq('/usr/bin')
      else
        expect(host.readlink('/etc/os-release', canonicalize: true).path).to eq('/usr/lib/os-release')
      end
    end
  end
end
