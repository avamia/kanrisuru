# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Yum do
  before(:all) do
    StubNetwork.stub!('centos')
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'centos-host',
      username: 'centos',
      keys: ['id_rsa']
    )
  end

  it 'responds to methods' do
    expect(host).to respond_to(:yum)
  end

  it 'responds to yum fields' do
    expect(Kanrisuru::Core::Yum::PackageOverview.new).to respond_to(
      :package, :architecture, :version, :installed
    )

    expect(Kanrisuru::Core::Yum::PackageSearchResult.new).to respond_to(
      :package, :architecture, :summary
    )

    expect(Kanrisuru::Core::Yum::PackageDetail.new).to respond_to(
      :package,
      :version,
      :release,
      :architecture,
      :install_size,
      :source,
      :yum_id,
      :repository,
      :summary,
      :url,
      :license,
      :description
    )

    expect(Kanrisuru::Core::Yum::Repolist.new).to respond_to(
      :id,
      :name,
      :status,
      :revision,
      :packages,
      :available_packages,
      :repo_size,
      :mirrors,
      :metalink,
      :updated,
      :baseurl,
      :expire,
      :filters,
      :filename
    )
  end
end
