# frozen_string_literal: true

RSpec.describe Kanrisuru::Remote::Fstab do
  it 'creates fstab options' do
    options = Kanrisuru::Remote::Fstab::Options.new('ext4', 'user,defaults,resgid=1000,resuid=1000')

    expect(options.class).to eq(Kanrisuru::Remote::Fstab::Options)
    expect(options.to_s).to eq('user,defaults,resgid=1000,resuid=1000')

    options = Kanrisuru::Remote::Fstab::Options.new('fat', user: true, defaults: true, uid: 1000, gid: 1000)

    expect(options.class).to eq(Kanrisuru::Remote::Fstab::Options)
    expect(options.to_s).to eq('user,defaults,uid=1000,gid=1000')

    options['user'] = false
    options['fat'] = 16
    options[:uid] = 0
    options[:gid] = 0

    expect(options.to_s).to eq('defaults,uid=0,gid=0,fat=16')
  end
end
