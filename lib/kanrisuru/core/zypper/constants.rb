module Kanrisuru
  module Core
    module Zypper
      module Constants
        PACKAGE_TYPES = %w[package patch pattern product srcpackage application].freeze
        PATCH_CATEGORIES = %w[security recommended optional feature document yast].freeze
        PATCH_SEVERITIES = %w[critical important moderate low unspecified].freeze
        SOLVER_FOCUS_MODES = %w[job installed update].freeze
        MEDIUM_TYPES = %w[dir file cd dvd nfs iso http https ftp cifs smb hd].freeze

        EXIT_INF_UPDATE_NEEDED = 100
        EXIT_INF_SEC_UPDATE_NEEDED = 101
        EXIT_INF_REBOOT_NEEDED = 102
        EXIT_INF_RESTART_NEEDED = 103
        EXIT_INF_CAP_NOT_FOUND = 104

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
end
