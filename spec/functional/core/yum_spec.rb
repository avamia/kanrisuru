# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Yum do
  TestHosts.each_os(only: %w[fedora rhel centos]) do |os_name|
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

      it 'upgrades packages' do
        host.su('root')
        result = host.yum('upgrade')
        expect(result).to be_success
      end

      it 'updates packages' do
        host.su('root')
        result = host.yum('update')
        expect(result).to be_success
      end

      it 'installs local package from RPM' do
        case os_name
        when 'fedora'
          package = 'rpmfusion-free-release-32.noarch.rpm'
          url = "https://download1.rpmfusion.org/free/fedora/#{package}"

          result = host.wget(url)
          expect(result).to be_success
          file = host.file("~/#{package}")
          expect(file).to be_exists

          host.su('root')
          result = host.yum('localinstall', repos: file.expand_path)
          expect(result).to be_success
        end
      end

      it 'lists installed packages' do
        result = host.yum('list', installed: true)
        expect(result).to be_success
      end

      it 'lists repos' do
        result = host.yum('repolist')
        expect(result).to be_success
      end

      it 'lists installed repos' do
        result = host.yum('repolist', repos: 'updates')
        expect(result).to be_success
      end

      it 'searches a single package' do
        result = host.yum('search', packages: 'curl')
        expect(result).to be_success
      end

      it 'searches all packages' do
        result = host.yum('search', all: true, packages: %w[curl ffmpeg])
        expect(result).to be_success
      end

      it 'installs a package' do
        host.su('root')
        result = host.yum('install', packages: %(ffmpeg curl))
        expect(result).to be_success
      end

      it 'removes installed packages' do
        host.su('root')
        result = host.yum('remove', packages: ['ffmpeg'])
        expect(result).to be_success
      end

      it 'purges installed packages' do
        host.su('root')
        result = host.yum('erase', packages: ['ffmpeg'])
        expect(result).to be_success
      end

      it 'gets info for one package' do
        host.su('root')
        result = host.yum('info', packages: 'yum')
        expect(result).to be_success
      end

      it 'gets info for installed packages' do
        host.su('root')
        result = host.yum('info', installed: true)
        expect(result).to be_success
      end

      it 'cleans packages' do
        host.su('root')
        result = host.yum('clean', all: true)
        expect(result).to be_success
      end

      it 'autoremoves packages' do
        host.su('root')
        result = host.yum('autoremove')
        expect(result).to be_success
      end
    end
  end
end
