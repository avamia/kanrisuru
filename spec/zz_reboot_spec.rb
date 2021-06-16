# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::System do
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

      it 'cancels rebooting system' do
        host.su('root')
        result = host.reboot(time: 1000)
        expect(result).to be_success

        result = host.reboot(cancel: true)
        expect(result).to be_success

        result = host.reboot(time: '11:11', message: 'Rebooting system')
        expect(result).to be_success

        result = host.reboot(cancel: true)
        expect(result).to be_success
        host.disconnect
      end

      # it 'reboots system' do
      #   host.su('root')
      #   result = host.reboot(time: 'now')
      #   expect(result).to be_success
      # end

      # it 'powers off system' do
      #   host.su('root')
      #   result = host.poweroff(time: 'now')
      #   expect(result).to be_success
      # end
    end
  end
end
