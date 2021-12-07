# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'apt' do |os_name, host_json, _spec_dir|
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

    it 'installs package' do
      host.su('root')
      result = host.apt('install', packages: %w[ffmpeg curl])
      expect(result).to be_success

      result = host.which('ffmpeg')
      expect(result).to be_success
      paths = result.map(&:path)
      expect(paths).to include(match('ffmpeg'))

      result = host.which('curl')
      expect(result).to be_success
      paths = result.map(&:path)
      expect(paths).to include(match('curl'))
    end

    it 'removes installed packages' do
      host.su('root')
      result = host.apt('remove', packages: ['ffmpeg'])
      expect(result).to be_success
    end

    it 'purges installed packages' do
      host.su('root')
      result = host.apt('purge', packages: ['ffmpeg'])
      expect(result).to be_success
    end

    it 'removes unused packages' do
      host.su('root')
      result = host.apt('autoremove')
      expect(result).to be_success
    end

    it 'cleans packages' do
      host.su('root')
      result = host.apt('clean')
      expect(result).to be_success
    end

    it 'autocleans packages' do
      host.su('root')
      result = host.apt('autoclean')
      expect(result).to be_success
    end

    it 'updates packages' do
      host.su('root')
      result = host.apt('update')
      expect(result).to be_success
    end

    it 'upgrades packages' do
      host.su('root')
      result = host.apt('upgrade')
      expect(result).to be_success
    end

    it 'fully upgrades packages' do
      host.su('root')
      result = host.apt('full-upgrade')
      expect(result).to be_success
    end

    it 'shows details of listed packages' do
      result = host.apt('show', packages: %w[wget curl git sudo])
      expect(result).to be_success
    end

    it 'lists all packages' do
      host.su('root')
      result = host.apt('list')
      expect(result).to be_success
    end

    it 'lists installed packages' do
      host.su('root')
      result = host.apt('list', installed: true)
      expect(result).to be_success
    end

    it 'lists upgradable packages' do
      host.su('root')
      result = host.apt('list', upgradable: true)
      expect(result).to be_success
    end

    it 'lists all versions for packages' do
      host.su('root')
      result = host.apt('list', all_versions: true)
      expect(result).to be_success
    end

    it 'searches packages' do
      result = host.apt('search', query: 'wget')
      expect(result).to be_success
    end
  end
end
