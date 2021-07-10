# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Apt do
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

      describe 'apt install' do
        it 'installs package' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('install', packages: %w[ffmpeg curl])
            expect(result).to be_success
          end
        end
      end

      describe 'apt remove' do
        it 'removes installed packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('remove', packages: ['ffmpeg'])
            expect(result).to be_success
          end
        end

        it 'purges installed packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('purge', packages: ['ffmpeg'])
            expect(result).to be_success
          end
        end
      end

      describe 'apt autoremove' do
        it 'removes unused packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('autoremove')
            expect(result).to be_success
          end
        end
      end

      describe 'apt clean' do
        it 'cleans packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('clean')
            expect(result).to be_success
          end
        end

        it 'autocleans packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('autoclean')
            expect(result).to be_success
          end
        end
      end

      describe 'apt upgrade' do
        it 'upgrades packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('upgrade')
            expect(result).to be_success
          end
        end

        it 'fully upgrades packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('full-upgrade')
            expect(result).to be_success
          end
        end
      end

      describe 'apt show' do
        it 'shows details of listed packages' do
          case os_name
          when 'debian', 'ubuntu'
            result = host.apt('show', packages: %w[wget curl git sudo])
            expect(result).to be_success
          end
        end
      end

      describe 'apt list' do
        it 'lists all packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('list')
            expect(result).to be_success
          end
        end

        it 'lists installed packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('list', installed: true)
            expect(result).to be_success
          end
        end

        it 'lists upgradable packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('list', upgradable: true)
            expect(result).to be_success
          end
        end

        it 'lists all versions for packages' do
          case os_name
          when 'debian', 'ubuntu'
            host.su('root')
            result = host.apt('list', all_versions: true)
            expect(result).to be_success
          end
        end

        it 'searches packages' do
          case os_name
          when 'debian', 'ubuntu'
            result = host.apt('search', query: 'wget')
            expect(result).to be_success
          end
        end
      end
    end
  end
end
