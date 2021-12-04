# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Zypper do
  TestHosts.each_os(only: %w[sles opensuse]) do |os_name|
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

      def find_repo(host, repo_name)
        repos = host.zypper('repos').data
        repos.find { |repo| repo.alias == repo_name }
      end

      it 'lists repos' do
        result = host.zypper('repos')
        expect(result).to be_success
      end

      it 'installs a package' do
        host.su('root')
        result = host.zypper('install', packages: 'nginx')
        expect(result).to be_success
      end

      it 'installs multiple packages' do
        host.su('root')
        result = host.zypper('install', packages: %w[curl nginx])
        expect(result).to be_success
      end

      it 'removes a package' do
        host.su('root')
        result = host.zypper('remove', packages: ['nginx'])
        expect(result).to be_success
      end

      it 'lists updates' do
        result = host.zypper('list-updates')
        expect(result).to be_success
      end

      it 'lists patches' do
        result = host.zypper('list-patches')
        expect(result).to be_success
      end

      it 'lists important and secure patches' do
        result = host.zypper('list-patches', category: ['security'], severity: %w[important moderate])
        expect(result).to be_success
      end

      it 'lists patch check counts' do
        result = host.zypper('patch-check')
        expect(result).to be_success
      end

      it 'updates a package' do
        host.su('root')
        result = host.zypper('update', packages: 'curl')
        expect(result).to be_success
      end

      it 'gets info for one package' do
        result = host.zypper('info', packages: 'curl')
        expect(result).to be_success
      end

      it 'gets info for multiple packages' do
        result = host.zypper('info', packages: %w[curl wget git sudo])
        expect(result).to be_success
      end

      it 'gets info for type' do
        result = host.zypper('info', type: 'package', packages: 'gc*')
        expect(result).to be_success
      end

      it 'patches system' do
        host.su('root')
        result = host.zypper('patch', severity: 'moderate')
        expect(result).to be_success
      end

      it 'performs a dist-upgrade' do
        case os_name
        when 'opensuse'
          host.su('root')
          result = host.zypper('dist-upgrade', dry_run: true)
          expect(result).to be_success
        when 'sles'
          host.su('root')
          result = host.zypper('dist-upgrade', dry_run: true, auto_agree_with_licenses: true)
          expect(result).to be_success
        end
      end

      it 'searches for single package with match' do
        result = host.zypper('search', packages: 'gc*', sort_by_name: true)
        expect(result).to be_success
      end

      it 'searches for multiple packages' do
        result = host.zypper('search', packages: %w[nginx ffmpeg], sort_by_repo: true)
        expect(result).to be_success
      end

      it 'manages a repo' do
        repo_alias = 'graphics'
        if os_name == 'opensuse'
          repo_name = 'Graphics Project (openSUSE_Leap_15.2)'
          repo_uri = 'https://download.opensuse.org/repositories/graphics/openSUSE_Leap_15.2/'
        else
          repo_name = 'Graphics Project (openSUSE_Leap_15.3)'
          repo_uri = 'https://download.opensuse.org/repositories/graphics/openSUSE_Leap_15.3/'
        end

        url = "#{repo_uri}/#{repo_alias}.repo"

        host.su('root')
        result = host.zypper('addrepo', repos: url)
        expect(result).to be_success

        repo = find_repo(host, repo_alias)

        expect(repo).to be_instance_of(Kanrisuru::Core::Zypper::Repo)
        expect(repo.uri).to eq(repo_uri)
        expect(repo.name).to eq(repo_name)

        new_repo_alias = 'graphics-repo'
        result = host.zypper('renamerepo', repo: repo_alias, alias: new_repo_alias)
        expect(result).to be_success
        repo = find_repo(host, new_repo_alias)
        expect(repo.alias).to eq(new_repo_alias)

        result = host.zypper('modifyrepo', repos: new_repo_alias, disable: true)
        expect(result).to be_success
        repo = find_repo(host, new_repo_alias)
        expect(repo.enabled).to be_falsey

        result = host.zypper('removerepo', repos: new_repo_alias)
        expect(result).to be_success

        repo = find_repo(host, new_repo_alias)
        expect(repo).to be_nil
      end

      it 'refreshes repos' do
        host.su('root')
        result = host.zypper('refresh')
        expect(result).to be_success
      end

      it 'cleans repo caches' do
        host.su('root')
        result = host.zypper('clean')
        expect(result).to be_success
      end

      it 'lists services' do
        result = host.zypper('services')
        expect(result).to be_success
      end

      it 'refreshes services' do
        host.su('root')
        result = host.zypper('refresh-services')
        expect(result).to be_success
      end

      it 'manages locks' do
        host.su('root')
        result = host.zypper('addlock', lock: 'nginx', type: 'package')
        expect(result).to be_success

        result = host.zypper('locks')
        expect(result).to be_success

        lock = result.first
        expect(lock.name).to eq('nginx')
        expect(lock.type).to eq('package')

        result = host.zypper('removelock', lock: 'nginx')
        expect(result).to be_success
      end
    end
  end
end
