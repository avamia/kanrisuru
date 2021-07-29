# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Transfer do
  it 'responds to transfer fields' do
    expect(Kanrisuru::Core::Transfer::WGET_FILENAME_MODES).to eq(
      %w[unix windows nocontrol ascii lowercase uppercase]
    )

    expect(Kanrisuru::Core::Transfer::WGET_SSL_PROTO).to eq(
      %w[auto SSLv2 SSLv3 TLSv1]
    )
  end
end
