# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Dmi do
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

      it 'parses dmi values' do
        host.su('root')
        result = host.dmi
        expect(result).to be_success
      end

      it 'parses dmi values with types' do
        host.su('root')
        result = host.dmi(types: ['System', 3])
        expect(result).to be_success

        expect(result.find { |i| i.dmi_type == 'System' }).to be_instance_of(Kanrisuru::Core::Dmi::System)
        expect(result.find { |i| i.dmi_type == 'Chassis' }).to be_instance_of(Kanrisuru::Core::Dmi::Chassis)
      end
    end
  end
end
