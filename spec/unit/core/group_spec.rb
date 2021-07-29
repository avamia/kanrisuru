# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Group do
  it 'responds to group fields' do
    expect(Kanrisuru::Core::Group::Group.new).to respond_to(:gid, :name, :users)
    expect(Kanrisuru::Core::Group::GroupUser.new).to respond_to(:uid, :name)
  end
end
