# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Socket do
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

      it 'gets socket details' do
        result = host.ss
        expect(result).to be_success

        result = host.ss(state: 'listening')
        expect(result).to be_success
      end
    end
  end
end
