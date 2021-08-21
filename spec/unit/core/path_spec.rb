# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Path do
  it 'responds to path fields' do
    expect(Kanrisuru::Core::Path::FilePath.new).to respond_to(:path)
    expect(Kanrisuru::Core::Path::FileInfoId.new).to respond_to(
      :inode, :mode, :hard_links, :uid, :gid, :fsize, :date, :path, :type
    )
    expect(Kanrisuru::Core::Path::FileInfo.new).to respond_to(
      :inode, :mode, :hard_links, :owner, :group, :fsize, :date, :path, :type
    )
    expect(Kanrisuru::Core::Path::UserName.new).to respond_to(:user)
  end
end
