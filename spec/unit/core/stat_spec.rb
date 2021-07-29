# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Stat do
  it 'responds to stat fields' do
    expect(Kanrisuru::Core::Stat::FileStat.new).to respond_to(
      :mode, :blocks, :device, :file_type,
      :gid, :group, :links, :inode,
      :path, :fsize, :uid, :user,
      :last_access, :last_modified, :last_changed
    )
  end
end
