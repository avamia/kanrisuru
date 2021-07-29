# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Yum do
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
