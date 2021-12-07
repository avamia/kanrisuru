# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Result do
  let(:command) { Kanrisuru::Command.new('hello') }

  it 'initializes result' do
    command.handle_status(0)

    result = described_class.new(command)
    expect(result).to be_instance_of(Kanrisuru::Result)
  end

  it 'initializes with block and return struct fields' do
    command.handle_status(0)
    command.handle_data('world')

    result = described_class.new(command) do |cmd|
      Struct.new(:output).new(cmd.to_s)
    end

    expect(result).to respond_to(:output)
    expect(result[:output]).to eq('world')
    expect(result.data.output).to eq('world')
  end

  it 'is success from command' do
    command.handle_status(0)
    result = described_class.new(command)
    expect(result).to be_success
  end

  it 'is failure from command' do
    command.handle_status(1)
    result = described_class.new(command)
    expect(result).to be_failure
  end

  it 'returns exit status' do
    command.handle_status(0)
    result = described_class.new(command)
    expect(result.status).to eq(0)

    command.handle_status(1)

    result = described_class.new(command)
    expect(result.status).to eq(1)
  end

  it 'returns to_s on string result' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      'output'
    end

    expect(result.to_s).to eq('output')
  end

  it 'returns to_a on array result' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      [0, 1, 2, 3]
    end

    expect(result.to_a).to eq([0, 1, 2, 3])
  end

  it 'returns to_a on non-array result' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      'output'
    end

    expect(result.to_a).to eq(['output'])
  end

  it 'returns to_i on integer return value' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      55
    end

    expect(result.to_i).to eq(55)
  end

  it 'returns to_i on non-integer return value' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      '100'
    end

    expect(result.to_i).to eq(100)

    result = described_class.new(command) do |_cmd|
      'hello'
    end

    expect(result.to_i).to eq(0)

    result = described_class.new(command) do |_cmd|
      [0, 1, 2, 3]
    end

    expect(result.to_i).to eq([0, 1, 2, 3])

    result = described_class.new(command) do |_cmd|
      %w[0 1 2 3]
    end

    expect(result.to_i).to eq([0, 1, 2, 3])

    result = described_class.new(command)
    expect(result.to_i).to be_nil
  end

  it 'raises error on to_i for invalid data type' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      { 'hello' => 'world' }
    end

    expect do
      result.to_i
    end.to raise_error(NoMethodError)
  end

  it 'returns success string variant on inspect' do
    command.handle_status(0)
    result = described_class.new(command) do |_cmd|
      'hello'
    end

    expect(result.inspect).to eq(
      "#<Kanrisuru::Result:0x#{result.object_id} @status=0 @data=\"hello\" @command=#{command.prepared_command}>"
    )
  end

  it 'returns error string variant on inspect' do
    command.handle_status(1)
    command.handle_data('error: this is an error')
    result = described_class.new(command) do |_cmd|
      'hello'
    end

    expect(result.inspect).to eq(
      "#<Kanrisuru::Result:0x#{result.object_id} @status=1 @error=[\"error: this is an error\"] @command=#{command.prepared_command}>"
    )
  end
end
