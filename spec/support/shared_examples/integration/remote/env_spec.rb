# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples "env" do |os_name, host_json, spec_dir|
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

    it 'sets env var' do
      host.env['HELLO'] = 'world'
      host.env['KANRISURU'] = 'manage'

      expect(host.env['KANRISURU']).to eq('manage')
      expect(host.env.to_s).to eq('export HELLO=world; export KANRISURU=manage;')
      expect(host.env.to_h).to eq({ 'HELLO' => 'world', 'KANRISURU' => 'manage' })

      command = Kanrisuru::Command.new('echo $KANRISURU $HELLO')
      host.execute_shell(command)

      expect(command.to_s).to eq('manage world')
    end
  end
end
