# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Find do
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

  it 'responds to methods' do
    expect(host).to respond_to(:find)
  end

  it 'responds to find fields' do
    expect(Kanrisuru::Core::Find::FilePath.new).to respond_to(:path)
    expect(Kanrisuru::Core::Find::REGEX_TYPES).to(
      eq(['emacs', 'posix-awk', 'posix-basic', 'posix-egrep', 'posix-extended'])
    )
  end
end
