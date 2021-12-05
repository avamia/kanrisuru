# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Remote::Os do
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

      it 'detects os specs' do
        expect(host.os.kernel).to eq(host_json['kernel'])
        expect(host.os.processor).to eq('x86_64')

        case os_name
        when 'opensuse'
          expect(host.os.release).to eq('opensuse_leap')
        else
          expect(host.os.release).to eq(os_name)
        end

        expect(host.os.version).to be > 0.00

        case os_name
        when 'debian'
          expect(host.os.version).to eq(10)
        when 'ubuntu'
          expect(host.os.version).to eq(18.04)
        when 'fedora'
          expect(host.os.version).to eq(32)
        when 'centos'
          expect(host.os.version).to eq(7)
        when 'opensuse'
          expect(host.os.version).to eq(15.2)
        when 'rhel'
          expect(host.os.version).to eq(7.9)
        end
      end

      it 'gets uname' do
        expect(host.os.uname).to eq(host_json['kernel'])
      end

      it 'gets uname details' do
        host.os.uname(
          kernel_name: true,
          hardware_platform: true,
          operating_system: true
        )
      end
    end
  end
end
