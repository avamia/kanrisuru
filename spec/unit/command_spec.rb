# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Command do
  it 'responds to methods' do
    command = described_class.new('ls')
    expect(command).to respond_to(:exit_status)
    expect(command).to respond_to(:raw_result)
    expect(command).to respond_to(:program)
    expect(command).to respond_to(:success?)
    expect(command).to respond_to(:failure?)
    expect(command).to respond_to(:to_i)
    expect(command).to respond_to(:to_s)
    expect(command).to respond_to(:to_a)
    expect(command).to respond_to(:to_json)
    expect(command).to respond_to(:prepared_command)
    expect(command).to respond_to(:raw_command)
    expect(command).to respond_to(:handle_status)
    expect(command).to respond_to(:handle_data)
    expect(command).to respond_to(:handle_signal)
    expect(command).to respond_to(:+)
    expect(command).to respond_to(:<<)
    expect(command).to respond_to(:|)
    expect(command).to respond_to(:pipe)
    expect(command).to respond_to(:append_value)
    expect(command).to respond_to(:append_arg)
    expect(command).to respond_to(:append_flag)
    expect(command).to respond_to(:append_valid_exit_code)
  end

  it 'does not append nil array values' do
    command = described_class.new('hello')
    command.append_array(nil)
    expect(command.raw_command).to eq('hello')
  end

  it 'appends string array values' do
    command = described_class.new('ls')
    command.append_array('/etc')
    expect(command.raw_command).to eq('ls /etc')
  end

  it 'appends array values' do
    command = described_class.new('ls')
    command.append_array(['/proc/', '/etc', '/var', '/dev'])
    expect(command.raw_command).to eq('ls /proc/ /etc /var /dev')
  end
end
