# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Mode do
  it 'parses int mode' do
    mode = described_class.new('644')
    expect(mode.directory?).to eq(false)

    expect(mode.owner.read?).to eq(true)
    expect(mode.owner.write?).to eq(true)
    expect(mode.owner.execute?).to eq(false)
    expect(mode.owner.all?).to eq(false)
    expect(mode.owner.to_i).to eq(6)
    expect(mode.owner.symbolic).to eq('rw-')

    expect(mode.group.read?).to eq(true)
    expect(mode.group.write?).to eq(false)
    expect(mode.group.execute?).to eq(false)
    expect(mode.group.all?).to eq(false)
    expect(mode.group.to_i).to eq(4)
    expect(mode.group.symbolic).to eq('r--')

    expect(mode.other.read?).to eq(true)
    expect(mode.other.write?).to eq(false)
    expect(mode.other.execute?).to eq(false)
    expect(mode.other.all?).to eq(false)
    expect(mode.other.to_i).to eq(4)
    expect(mode.other.symbolic).to eq('r--')
  end

  it 'parses int mode octal' do
    mode = described_class.new(0o644)
    expect(mode.directory?).to eq(false)

    expect(mode.owner.read?).to eq(true)
    expect(mode.owner.write?).to eq(true)
    expect(mode.owner.execute?).to eq(false)
    expect(mode.owner.all?).to eq(false)
    expect(mode.owner.to_i).to eq(6)
    expect(mode.owner.symbolic).to eq('rw-')

    expect(mode.group.read?).to eq(true)
    expect(mode.group.write?).to eq(false)
    expect(mode.group.execute?).to eq(false)
    expect(mode.group.all?).to eq(false)
    expect(mode.group.to_i).to eq(4)
    expect(mode.group.symbolic).to eq('r--')

    expect(mode.other.read?).to eq(true)
    expect(mode.other.write?).to eq(false)
    expect(mode.other.execute?).to eq(false)
    expect(mode.other.all?).to eq(false)
    expect(mode.other.to_i).to eq(4)
    expect(mode.other.symbolic).to eq('r--')
  end

  it 'parses ref mode' do
    mode = described_class.new('drwxrwxrwx')
    expect(mode.directory?).to eq(true)

    expect(mode.owner.read?).to eq(true)
    expect(mode.owner.write?).to eq(true)
    expect(mode.owner.execute?).to eq(true)
    expect(mode.owner.all?).to eq(true)
    expect(mode.owner.to_i).to eq(7)
    expect(mode.owner.symbolic).to eq('rwx')

    expect(mode.group.read?).to eq(true)
    expect(mode.group.write?).to eq(true)
    expect(mode.group.execute?).to eq(true)
    expect(mode.group.all?).to eq(true)
    expect(mode.group.to_i).to eq(7)
    expect(mode.group.symbolic).to eq('rwx')

    expect(mode.other.read?).to eq(true)
    expect(mode.other.write?).to eq(true)
    expect(mode.other.execute?).to eq(true)
    expect(mode.other.all?).to eq(true)
    expect(mode.other.to_i).to eq(7)
    expect(mode.other.symbolic).to eq('rwx')

    mode = described_class.new("---x--x--x")
    expect(mode.directory?).to eq(false)
    expect(mode.numeric).to eq("111")

    expect(mode.owner.read?).to eq(false)
    expect(mode.owner.write?).to eq(false)
    expect(mode.owner.execute?).to eq(true)
    expect(mode.owner.all?).to eq(false)
    expect(mode.owner.to_i).to eq(1)
    expect(mode.owner.symbolic).to eq('--x')

    expect(mode.group.read?).to eq(false)
    expect(mode.group.write?).to eq(false)
    expect(mode.group.execute?).to eq(true)
    expect(mode.group.all?).to eq(false)
    expect(mode.group.to_i).to eq(1)
    expect(mode.group.symbolic).to eq('--x')

    expect(mode.other.read?).to eq(false)
    expect(mode.other.write?).to eq(false)
    expect(mode.other.execute?).to eq(true)
    expect(mode.other.all?).to eq(false)
    expect(mode.other.to_i).to eq(1)
    expect(mode.other.symbolic).to eq('--x')
  end

  it 'changes mode numerically globally' do
    mode = described_class.new(0o600)

    expect(mode.owner.read?).to eq(true)
    expect(mode.group.read?).to eq(false)
    expect(mode.other.read?).to eq(false)
    expect(mode.symbolic).to eq('-rw-------')

    mode.numeric = 0o644

    expect(mode.owner.read?).to eq(true)
    expect(mode.group.read?).to eq(true)
    expect(mode.other.read?).to eq(true)

    expect(mode.symbolic).to eq('-rw-r--r--')
    expect(mode.to_s).to eq('-rw-r--r--')
    expect(mode.numeric).to eq('644')
    expect(mode.to_i).to eq(0o644)
  end

  it 'changes mode symbolically globally' do
    mode = described_class.new(0o600)

    expect(mode.owner.read?).to eq(true)
    expect(mode.group.read?).to eq(false)
    expect(mode.other.read?).to eq(false)
    expect(mode.symbolic).to eq('-rw-------')

    mode.symbolic = '-rw-r--r--'

    expect(mode.owner.read?).to eq(true)
    expect(mode.group.read?).to eq(true)
    expect(mode.other.read?).to eq(true)

    expect(mode.symbolic).to eq('-rw-r--r--')
    expect(mode.to_s).to eq('-rw-r--r--')
    expect(mode.numeric).to eq('644')
    expect(mode.to_i).to eq(0o644)
  end

  it 'changes mode numerically each permission level boolean' do
    mode = described_class.new(0o600)

    expect(mode.other.read?).to eq(false)
    expect(mode.group.read?).to eq(false)

    mode.group.read = true
    mode.other.read = true

    expect(mode.group.read?).to eq(true)
    expect(mode.other.read?).to eq(true)

    expect(mode.symbolic).to eq('-rw-r--r--')
    expect(mode.to_s).to eq('-rw-r--r--')
    expect(mode.numeric).to eq('644')
    expect(mode.to_i).to eq(0o644)
  end

  it 'changes mode on each permission level symbolic' do
    mode = described_class.new(0o600)

    expect(mode.other.read?).to eq(false)
    expect(mode.group.read?).to eq(false)

    mode.group.symbolic = 'rw-'
    mode.other.symbolic = 'r--'

    expect(mode.group.read?).to eq(true)
    expect(mode.group.write?).to eq(true)
    expect(mode.other.read?).to eq(true)

    expect(mode.symbolic).to eq('-rw-rw-r--')
    expect(mode.to_s).to eq('-rw-rw-r--')
    expect(mode.numeric).to eq('664')
    expect(mode.to_i).to eq(0o664)
  end

  it 'changes mode globally using symoblic operator' do
    mode = described_class.new(0o601)

    expect(mode.other.read?).to eq(false)
    expect(mode.group.read?).to eq(false)
    expect(mode.symbolic).to eq('-rw------x')

    mode.symbolic = 'u=rwx,g+w,o-x'
    expect(mode.numeric).to eq('720')
    expect(mode.symbolic).to eq('-rwx-w----')

    mode.symbolic = 'a=r'
    expect(mode.symbolic).to eq('-r--r--r--')
    expect(mode.to_i).to eq(0o444)

    mode.symbolic = 'u-r,gu+x,a+w'
    expect(mode.numeric).to eq('376')
    expect(mode.symbolic).to eq('--wxrwxrw-')

    mode.symbolic = '-w'
    expect(mode.symbolic).to eq('---xr-xr--')
  end
end
