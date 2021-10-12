# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Memory do
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

      it 'gets memory details' do
        expect(host.memory.total(:gb)).to be >= 0.5
        expect(host.memory.free(:mb)).to be >= 10.0
        expect(host.memory.swap).to be_instance_of(Integer)
        expect(host.memory.swap_free).to be_instance_of(Integer)
      end
    end
  end
end
