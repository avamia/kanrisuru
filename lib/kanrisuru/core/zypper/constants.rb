# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
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
    end
  end
end
