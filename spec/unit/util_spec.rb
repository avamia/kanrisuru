# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Util do
  it 'gets present value' do
    expect(described_class.present?(1)).to eq(true)
    expect(described_class.present?(true)).to eq(true)
    expect(described_class.present?('a')).to eq(true)
    expect(described_class.present?(Class)).to eq(true)

    expect(described_class.present?(false)).to eq(false)
    expect(described_class.present?('')).to eq(false)
    expect(described_class.present?([])).to eq(false)
    expect(described_class.present?(nil)).to eq(false)
  end

  it 'camelizes strings' do
    expect(described_class.camelize('hello_world')).to eq('HelloWorld')
    expect(described_class.camelize('helloworld')).to eq('Helloworld')
    expect(described_class.camelize('HelloWorld')).to eq('HelloWorld')
  end

  it 'gets os family' do
    expect(Kanrisuru::Util::OsFamily['debian']).to match({
                                                           name: 'Debian',
                                                           os_family: 'linux',
                                                           upstream: 'linux',
                                                           model: 'open_source',
                                                           state: 'current',
                                                           type: 'distribution'
                                                         })
  end

  it 'detects family inclusion of distribution' do
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('linux', 'centos')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix_like', 'centos')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix', 'centos')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix_like', 'linux')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('linux', 'ubuntu')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('linux', 'debian')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('linux', 'linux_mint')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix', 'bsd')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix_like', 'open_bsd')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix_like', 'darwin')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('unix_like', 'pure_darwin')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('linux', 'redhat')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.family_include_distribution?('fedora', 'redhat')).to eq(false)
  end

  it 'detects upstream inclusion of distribution' do
    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('debian', 'ubuntu')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('debian', 'linux_mint')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('linux', 'linux_mint')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('fedora', 'redhat')).to eq(true)
    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('fedora', 'centos')).to eq(true)

    expect(Kanrisuru::Util::OsFamily.upstream_include_distribution?('unix_like', 'linux_mint')).to eq(false)
  end

  it 'converts from methods' do
    expect(Kanrisuru::Util::Bits.convert_from_kb(1_000, :mb)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_from_mb(1_000, :gb)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_from_gb(1_000, :tb)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_from_tb(1_000, :pb)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_from_pb(1_000, :pb)).to eq(1_000)
  end

  it 'converts bytes and bits' do
    expect(Kanrisuru::Util::Bits.convert_bytes(1_000, :kilobyte, :kilobyte)).to eq(1000)
    expect(Kanrisuru::Util::Bits.convert_bytes(1_000, :kilobyte, :kb)).to eq(1000)
    expect(Kanrisuru::Util::Bits.convert_bytes(100, :kilobit, :kilobit)).to eq(100)
    expect(Kanrisuru::Util::Bits.convert_bytes(800, :kilobit, :kilobyte)).to eq(100)
    expect(Kanrisuru::Util::Bits.convert_bytes(100, :kilobyte, :kilobit)).to eq(800)

    expect { Kanrisuru::Util::Bits.convert_bytes(100, :kilobyte, :kilobitt) }.to raise_error(ArgumentError)
    expect { Kanrisuru::Util::Bits.convert_bytes(100, :kilobytee, :kilobit) }.to raise_error(ArgumentError)
  end

  it 'converts power' do
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :deca)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :kilo)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :mega)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :giga)).to eq(-3)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :tera)).to eq(-4)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :peta)).to eq(-5)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :exa)).to eq(-6)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :zetta)).to eq(-7)
    expect(Kanrisuru::Util::Bits.convert_power(:deca, :yotta)).to eq(-8)

    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :deca)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :kilo)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :mega)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :giga)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :tera)).to eq(-3)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :peta)).to eq(-4)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :exa)).to eq(-5)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :zetta)).to eq(-6)
    expect(Kanrisuru::Util::Bits.convert_power(:kilo, :yotta)).to eq(-7)

    expect(Kanrisuru::Util::Bits.convert_power(:mega, :deca)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :kilo)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :mega)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :giga)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :tera)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :peta)).to eq(-3)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :exa)).to eq(-4)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :zetta)).to eq(-5)
    expect(Kanrisuru::Util::Bits.convert_power(:mega, :yotta)).to eq(-6)

    expect(Kanrisuru::Util::Bits.convert_power(:giga, :deca)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :kilo)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :mega)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :giga)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :tera)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :peta)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :exa)).to eq(-3)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :zetta)).to eq(-4)
    expect(Kanrisuru::Util::Bits.convert_power(:giga, :yotta)).to eq(-5)

    expect(Kanrisuru::Util::Bits.convert_power(:tera, :deca)).to eq(4)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :kilo)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :mega)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :giga)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :tera)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :peta)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :exa)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :zetta)).to eq(-3)
    expect(Kanrisuru::Util::Bits.convert_power(:tera, :yotta)).to eq(-4)

    expect(Kanrisuru::Util::Bits.convert_power(:peta, :deca)).to eq(5)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :kilo)).to eq(4)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :mega)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :giga)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :tera)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :peta)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :exa)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :zetta)).to eq(-2)
    expect(Kanrisuru::Util::Bits.convert_power(:peta, :yotta)).to eq(-3)

    expect(Kanrisuru::Util::Bits.convert_power(:exa, :deca)).to eq(6)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :kilo)).to eq(5)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :mega)).to eq(4)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :giga)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :tera)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :peta)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :exa)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :zetta)).to eq(-1)
    expect(Kanrisuru::Util::Bits.convert_power(:exa, :yotta)).to eq(-2)

    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :deca)).to eq(7)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :kilo)).to eq(6)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :mega)).to eq(5)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :giga)).to eq(4)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :tera)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :peta)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :exa)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :zetta)).to eq(0)
    expect(Kanrisuru::Util::Bits.convert_power(:zetta, :yotta)).to eq(-1)

    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :deca)).to eq(8)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :kilo)).to eq(7)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :mega)).to eq(6)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :giga)).to eq(5)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :tera)).to eq(4)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :peta)).to eq(3)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :exa)).to eq(2)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :zetta)).to eq(1)
    expect(Kanrisuru::Util::Bits.convert_power(:yotta, :yotta)).to eq(0)
  end
end
