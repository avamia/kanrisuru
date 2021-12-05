# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Remote::Cpu do
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

      it 'gets cpu details' do
        expect(host.cpu.cores).to eq(1)
        expect(host.cpu.total).to eq(1)
        expect(host.cpu.count).to eq(1)

        expect(host.cpu.threads_per_core).to eq(1)
        expect(host.cpu.cores_per_socket).to eq(1)
        expect(host.cpu.sockets).to eq(1)

        expect(host.cpu.hyperthreading?).to eq(false)
      end

      it 'gets cpu load average' do
        expect(host.cpu.load_average).to be_instance_of(Array)
        expect(host.cpu.load_average1).to be_instance_of(Float)
        expect(host.cpu.load_average5).to be_instance_of(Float)
        expect(host.cpu.load_average15).to be_instance_of(Float)
      end
    end
  end
end
