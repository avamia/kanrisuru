# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Dmi do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'prepares dmi command' do
    expect_command(host.dmi, 'dmidecode')
    expect_command(host.dmi(types: 'BIOS'), 'dmidecode --type 0')
    expect_command(host.dmi(types: 1), 'dmidecode --type 1')

    expect do
      host.dmi(types: 'hello')
    end.to raise_error(ArgumentError)

    expect_command(host.dmi(types: [
                              'BIOS',
                              'System',
                              'Baseboard',
                              'Chassis',
                              'Processor',
                              'Memory Controller',
                              'Memory Module',
                              'Cache',
                              'Port Connector',
                              'System Slots',
                              'On Board Devices',
                              'OEM Strings',
                              'System Configuration Options',
                              'BIOS Language',
                              'Group Associations',
                              'System Event Log',
                              'Physical Memory Array',
                              'Memory Device',
                              '32-bit Memory Error',
                              'Memory Array Mapped Address',
                              'Memory Device Mapped Address',
                              'Built-in Pointing Device',
                              'Portable Battery',
                              'System Reset',
                              'Hardware Security',
                              'System Power Controls',
                              'Voltage Probe',
                              'Cooling Device',
                              'Temperature Probe',
                              'Electrical Current Probe',
                              'Out-of-band Remote Access',
                              'Boot Integrity Services',
                              'System Boot',
                              '64-bit Memory Error',
                              'Management Device',
                              'Management Device Component',
                              'Management Device Threshold Data',
                              'Memory Channel',
                              'IPMI Device',
                              'System Power Supply',
                              'Additional Information',
                              'Onboard Devices Extended Information',
                              'Management Controller Host Interface',
                              'TPM Device'
                            ]), 'dmidecode --type 0 --type 1 --type 2 --type 3 --type 4 --type 5 --type 6 --type 7 --type 8 --type 9 --type 10 --type 11 --type 12 --type 13 --type 14 --type 15 --type 16 --type 17 --type 18 --type 19 --type 20 --type 21 --type 22 --type 23 --type 24 --type 25 --type 26 --type 27 --type 28 --type 29 --type 30 --type 31 --type 32 --type 33 --type 34 --type 35 --type 36 --type 37 --type 38 --type 39 --type 40 --type 41 --type 42 --type 43')
  end
end
