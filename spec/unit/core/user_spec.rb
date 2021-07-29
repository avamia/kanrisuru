# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::User do
  it 'responds to user fields' do
    expect(Kanrisuru::Core::User::User.new).to respond_to(:uid, :name, :home, :shell, :groups)
    expect(Kanrisuru::Core::User::UserGroup.new).to respond_to(:gid, :name)
    expect(Kanrisuru::Core::User::FilePath.new).to respond_to(:path)
  end
end
