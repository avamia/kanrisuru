# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Zypper do
  it 'responds to zypper fields' do
    expect(Kanrisuru::Core::Zypper::PACKAGE_TYPES).to(
      eq(%w[package patch pattern product srcpackage application])
    )

    expect(Kanrisuru::Core::Zypper::PATCH_CATEGORIES).to(
      eq(%w[security recommended optional feature document yast])
    )

    expect(Kanrisuru::Core::Zypper::PATCH_SEVERITIES).to(
      eq(%w[critical important moderate low unspecified])
    )

    expect(Kanrisuru::Core::Zypper::SOLVER_FOCUS_MODES).to(
      eq(%w[job installed update])
    )

    expect(Kanrisuru::Core::Zypper::MEDIUM_TYPES).to(
      eq(%w[dir file cd dvd nfs iso http https ftp cifs smb hd])
    )

    expect(Kanrisuru::Core::Zypper::EXIT_INF_UPDATE_NEEDED).to(
      eq(100)
    )

    expect(Kanrisuru::Core::Zypper::EXIT_INF_SEC_UPDATE_NEEDED).to(
      eq(101)
    )

    expect(Kanrisuru::Core::Zypper::EXIT_INF_REBOOT_NEEDED).to(
      eq(102)
    )

    expect(Kanrisuru::Core::Zypper::EXIT_INF_RESTART_NEEDED).to(
      eq(103)
    )

    expect(Kanrisuru::Core::Zypper::EXIT_INF_CAP_NOT_FOUND).to(
      eq(104)
    )

    expect(Kanrisuru::Core::Zypper::Repo.new).to respond_to(
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
    expect(Kanrisuru::Core::Zypper::Service.new).to respond_to(
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
    expect(Kanrisuru::Core::Zypper::SearchResult.new).to respond_to(
      :repository,
      :package,
      :status,
      :type,
      :version,
      :architecture
    )
    expect(Kanrisuru::Core::Zypper::PackageDetail.new).to respond_to(
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
    expect(Kanrisuru::Core::Zypper::PackageUpdate.new).to respond_to(
      :repository,
      :package,
      :current_version,
      :available_version,
      :architecture
    )
    expect(Kanrisuru::Core::Zypper::PatchUpdate.new).to respond_to(
      :repository,
      :patch,
      :category,
      :severity,
      :interactive,
      :status,
      :summary
    )
    expect(Kanrisuru::Core::Zypper::PatchCount.new).to respond_to(
      :category,
      :updatestack,
      :patches
    )
    expect(Kanrisuru::Core::Zypper::Lock.new).to respond_to(
      :number,
      :name,
      :matches,
      :type,
      :repository
    )
  end
end
