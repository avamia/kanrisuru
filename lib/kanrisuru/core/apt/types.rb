# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      Source = Struct.new(:url, :dist, :architecture)
      PackageOverview = Struct.new(:package, :version, :suites, :architecture, :installed, :upgradeable, :automatic)
      PackageDetail = Struct.new(
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
end
