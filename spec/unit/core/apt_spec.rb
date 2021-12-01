# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Apt do
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
    expect(host).to respond_to(:apt)
  end

  it 'responds to apt fields' do
    expect(Kanrisuru::Core::Apt::Source.new).to respond_to(
      :url, :dist, :architecture
    )

    expect(Kanrisuru::Core::Apt::PackageOverview.new).to respond_to(
      :package, :version, :suites, :architecture, :installed, :upgradeable, :automatic
    )

    expect(Kanrisuru::Core::Apt::PackageDetail.new).to respond_to(
      :package,
      :version,
      :priority,
      :section,
      :origin,
      :maintainer,
      :original_maintainer,
      :bugs,
      :install_size,
      :dependencies,
      :recommends,
      :provides,
      :suggests,
      :breaks,
      :conflicts,
      :replaces,
      :homepage,
      :task,
      :supported,
      :download_size,
      :apt_manual_installed,
      :apt_sources,
      :description,
      :summary
    )
  end
end
