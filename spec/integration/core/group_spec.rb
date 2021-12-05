# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Core::Group do
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

      it 'gets gid for group' do
        case os_name
        when 'opensuse', 'sles'
          expect(host.get_gid('users').to_i).to eq(100)
        else
          expect(host.get_gid(host_json['username']).to_i).to eq(1000)
        end

        expect(host.get_gid('asdf').to_i).to eq(nil)
      end

      it 'gets group details' do
        case os_name
        when 'opensuse', 'sles'
          result = host.get_group('users')
          expect(result.success?).to eq(true)
          expect(result.gid).to eq(100)
          expect(result.name).to eq('users')
        else
          result = host.get_group(host_json['username'])
          expect(result.success?).to eq(true)
          expect(result.gid).to eq(1000)
          expect(result.name).to eq(host_json['username'])
        end

        expect(result).to respond_to(:users)
      end

      it 'manages a group' do
        ## Need priviledge escalation to manage group
        host.su('root')

        if host.group?('rspec')
          expect(host.delete_group('rspec').success?).to eq(true)
        elsif host.group?('minitest')
          expect(host.delete_group('minitest').success?).to eq(true)
        end

        expect(host.create_group('rspec').gid).to be >= 1000
        expect(host.update_group('rspec', gid: 1005, new_name: 'minitest').gid).to eq(1005)
        expect(host.delete_group('minitest').success?).to eq(true)
      end
    end
  end
end
