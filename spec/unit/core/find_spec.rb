# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Find do
  it 'responds to find fields' do
    expect(Kanrisuru::Core::Find::FilePath.new).to respond_to(:path)
    expect(Kanrisuru::Core::Find::REGEX_TYPES).to(
      eq(['emacs', 'posix-awk', 'posix-basic', 'posix-egrep', 'posix-extended'])
    )
  end
end
