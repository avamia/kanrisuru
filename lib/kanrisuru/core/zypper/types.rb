module Kanrisuru
  module Core
    module Zypper
      Repo = Struct.new(
        :number,
        :alias,
        :name,
        :enabled,
        :gpg_check,
        :refresh,
        :priority,
        :type,
        :uri,
        :service
      )

      Service = Struct.new(
        :number,
        :alias,
        :name,
        :enabled,
        :gpg_check,
        :refresh,
        :priority,
        :type,
        :uri
      )

      SearchResult = Struct.new(
        :repository,
        :package,
        :status,
        :type,
        :version,
        :architecture
      )

      PackageDetail = Struct.new(
        :repository,
        :package,
        :version,
        :architecture,
        :vendor,
        :support_level,
        :install_size,
        :installed,
        :status,
        :source_package,
        :summary,
        :description
      )

      PackageUpdate = Struct.new(
        :repository,
        :package,
        :current_version,
        :available_version,
        :architecture
      )

      PatchUpdate = Struct.new(
        :repository,
        :patch,
        :category,
        :severity,
        :interactive,
        :status,
        :summary
      )

      PatchCount = Struct.new(
        :category,
        :updatestack,
        :patches
      )

      Lock = Struct.new(
        :number,
        :name,
        :matches,
        :type,
        :repository
      )
    end
  end
end
