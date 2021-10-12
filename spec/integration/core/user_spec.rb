# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::User do
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

      after(:all) do
        host_json = TestHosts.host(os_name)
        host = Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )

        host.su('root')
        host.user?('rails')
        host.delete_user('rails').inspect if host.user?('rails')
        host.rmdir('/home/rails') if host.dir?('/home/rails')
        host.disconnect
      end

      it 'gets uid for user' do
        expect(host.get_uid(host_json['uername']).to_i).to eq(1000)
        expect(host.get_uid('asdf').to_i).to eq(nil)
      end

      it 'gets a user details' do
        result = host.get_user(host_json['username'])
        expect(result.uid).to eq(1000)
        expect(result.name).to eq(host_json['username'])
        expect(result.home.path).to eq(host_json['home'])

        case os_name
        when 'opensuse', 'sles'
          expect(result.groups[0]).to have_attributes(gid: 100, name: 'users')
        else
          expect(result.groups[0]).to have_attributes(gid: 1000, name: host_json['username'])
        end
      end

      it 'manages a user' do
        ## Need priviledge escalation to manage group
        host.su('root')

        result = host.create_user('rails', password: '123456', groups: %w[mail tty])
        expect(result.success?).to eq(true)
        expect(result.uid).to eq(1001)
        expect(result.groups.length).to eq(3)
        expect(result.shell.path).to eq('/bin/false')
        expect(result.home.path).to eq('/home/rails')

        result = host.update_user('rails', uid: 1002, shell: '/bin/bash', groups: ['audio'], append: true)

        expect(result.uid).to eq(1002)
        expect(result.shell.path).to eq('/bin/bash')
        expect(result.groups.length).to eq(4)

        expect(host.delete_user('rails').success?).to eq(true) if host.user?('rails')
      end
    end
  end
end
