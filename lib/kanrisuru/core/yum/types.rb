# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      PackageOverview = Struct.new(:package, :architecture, :version, :installed)
      PackageSearchResult = Struct.new(:package, :architecture, :summary)
      PackageDetail = Struct.new(
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

      Repolist = Struct.new(
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
end
