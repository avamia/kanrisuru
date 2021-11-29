# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Cpu do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host1) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'responds to methods' do
    cpu = Kanrisuru::Remote::Cpu.new(host1)

    expect(cpu).to respond_to(:load_average)
    expect(cpu).to respond_to(:load_average1)
    expect(cpu).to respond_to(:load_average5)
    expect(cpu).to respond_to(:load_average15)
    expect(cpu).to respond_to(:sockets)
    expect(cpu).to respond_to(:cores)
    expect(cpu).to respond_to(:total)
    expect(cpu).to respond_to(:count)
    expect(cpu).to respond_to(:threads_per_core)
    expect(cpu).to respond_to(:cores_per_socket)
    expect(cpu).to respond_to(:numa_nodes)
    expect(cpu).to respond_to(:vendor_id)
    expect(cpu).to respond_to(:cpu_family)
    expect(cpu).to respond_to(:model)
    expect(cpu).to respond_to(:model_name)
    expect(cpu).to respond_to(:byte_order)
    expect(cpu).to respond_to(:address_sizes)
    expect(cpu).to respond_to(:cpu_mhz)
    expect(cpu).to respond_to(:cpu_max_mhz)
    expect(cpu).to respond_to(:cpu_min_mhz)
    expect(cpu).to respond_to(:hypervisor)
    expect(cpu).to respond_to(:virtualization_type)
    expect(cpu).to respond_to(:flags)
    expect(cpu).to respond_to(:hyperthreading?)
  end
end