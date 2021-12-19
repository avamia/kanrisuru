# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Zypper do
  before(:all) do
    StubNetwork.stub!(:opensuse)
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'opensuse-host',
      username: 'opensuse',
      keys: ['id_rsa']
    )
  end

  %w[addlock al].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, lock: 'nginx'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addlock nginx')

      expect_command(host.zypper(action_variant,
                                 lock: 'nginx',
                                 type: 'package',
                                 config_file: '/etc/zypp/zypp.conf'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --config /etc/zypp/zypp.conf addlock -t package nginx')
    end
  end

  %w[locks ll].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet locks --matches')
    end
  end

  %w[removelock rl].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, lock: 'gcc'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removelock gcc')

      expect_command(host.zypper(action_variant, lock: 'gcc', type: 'patch'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removelock -t patch gcc')
    end
  end

  %w[cleanlocks cl].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev cleanlocks')
    end
  end

  %w[repos lr].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev repos --details')
    end
  end

  %w[refresh ref].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev refresh')

      expect_command(host.zypper(action_variant,
                                 force: true,
                                 force_build: true,
                                 force_download: true,
                                 build_only: true,
                                 download_only: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev refresh --force --force-build --force-download --build-only --download-only')
    end
  end

  %w[modifyrepo mr].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, repos: 'graphics'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo graphics')

      expect_command(host.zypper(action_variant,
                                 repos: 'graphics',
                                 name: 'graphics-alias',
                                 priority: 1),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --name graphics-alias --priority 1 graphics')

      expect_command(host.zypper(action_variant,
                                 disable: true,
                                 remote: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --disable --remote')

      expect_command(host.zypper(action_variant,
                                 enable: true,
                                 local: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --enable --local')

      expect_command(host.zypper(action_variant,
                                 refresh: true,
                                 all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --refresh --all')

      expect_command(host.zypper(action_variant,
                                 no_refresh: true,
                                 all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --no-refresh --all')

      expect_command(host.zypper(action_variant,
                                 keep_packages: true,
                                 all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --keep-packages --all')

      expect_command(host.zypper(action_variant,
                                 no_keep_packages: true,
                                 all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --no-keep-packages --all')

      expect_command(host.zypper(action_variant,
                                 gpgcheck: true,
                                 gpgcheck_strict: true,
                                 gpgcheck_allow_unsigned: true,
                                 gpgcheck_allow_unsigned_repo: true,
                                 gpgcheck_allow_unsigned_package: true,
                                 default_gpgcheck: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --gpgcheck --gpgcheck-strict --gpgcheck-allow-unsigned --gpgcheck-allow-unsigned-repo --gpgcheck-allow-unsigned-package --default-gpgcheck')

      expect_command(host.zypper(action_variant,
                                 medium_type: 'file'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyrepo --medium-type file')

      expect do
        host.zypper(action_variant, medium_type: 'tap')
      end.to raise_error(ArgumentError)
    end
  end

  %w[addrepo ar].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, repos: 'graphics'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addrepo --repo graphics')

      expect_command(host.zypper(action_variant, repos: %w[graphics repo-debug]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addrepo --repo graphics --repo repo-debug')

      expect_command(host.zypper(action_variant,
                                 check: true,
                                 enable: true,
                                 refresh: true,
                                 keep_packages: true,
                                 gpgcheck: true,
                                 gpgcheck_strict: true,
                                 gpgcheck_allow_unsigned: true,
                                 gpgcheck_allow_unsigned_repo: true,
                                 gpgcheck_allow_unsigned_package: true,
                                 default_gpgcheck: true,
                                 repos: 'graphics'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addrepo --check --enable --refresh --keep-packages --gpgcheck --gpgcheck-strict --gpgcheck-allow-unsigned --gpgcheck-allow-unsigned-repo --gpgcheck-allow-unsigned-package --default-gpgcheck --repo graphics')

      expect_command(host.zypper(action_variant,
                                 no_check: true,
                                 disable: true,
                                 no_refresh: true,
                                 no_keep_packages: true,
                                 priority: true,
                                 no_gpgcheck: true,
                                 repos: 'graphics'), 'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addrepo --no-check --disable --no-refresh --no-keep-packages --priority true --no-gpgcheck --repo graphics')
    end
  end

  %w[removerepo rr].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, repos: 'graphics'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removerepo graphics')

      expect_command(host.zypper(action_variant,
                                 repos: %w[graphics repo-debug],
                                 loose_auth: true,
                                 loose_query: true,
                                 all: true,
                                 medium_type: 'nfs'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removerepo --loose-auth --loose-query --all --medium-type nfs graphics repo-debug')

      expect_command(host.zypper(action_variant,
                                 repos: %w[graphics repo-debug],
                                 local: true,
                                 remote: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removerepo --local --remote graphics repo-debug')

      expect do
        host.zypper(action_variant, repos: %w[graphics repo-debug], medium_type: 'floppy')
      end.to raise_error(ArgumentError)
    end
  end

  %w[renamerepo nr].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, repo: 'graphics', alias: 'graphics-alias'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev renamerepo graphics graphics-alias')
    end
  end

  %w[addservice as].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant,
                                 service: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/',
                                 alias: 'repo-database'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addservice https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/ repo-database')

      expect_command(host.zypper(action_variant,
                                 service: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/',
                                 alias: 'repo-database',
                                 disable: true,
                                 refresh: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev addservice --disable --refresh https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/ repo-database')

      expect_command(host.zypper(action_variant,
                                 service: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/',
                                 name: 'Database Repository',
                                 enable: true,
                                 no_refresh: true,
                                 alias: 'repo-database'),
                     "zypper --non-interactive --ignore-unknown --no-color --no-abbrev addservice --name 'Database Repository' --enable --no-refresh https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/ repo-database")
    end
  end

  %w[removeservice rs].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, service: 'repo-source-non-oss'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removeservice repo-source-non-oss')

      expect_command(host.zypper(action_variant,
                                 loose_auth: true,
                                 loose_query: true,
                                 service: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev removeservice --loose-auth --loose-query https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/')

      expect_command(host.zypper(action_variant, service: 'Debug Repository (Non-OSS)'),
                     "zypper --non-interactive --ignore-unknown --no-color --no-abbrev removeservice 'Debug Repository (Non-OSS)'")
    end
  end

  %w[modifyservice ms].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, service: 'repo-database', no_refresh: true, enable: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --enable --no-refresh repo-database')

      expect_command(host.zypper(action_variant,
                                 service: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/',
                                 name: "'Database Repository OSS'",
                                 disable: true,
                                 refresh: true),
                     "zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --name 'Database Repository OSS' --disable --refresh https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/")

      expect_command(host.zypper(action_variant,
                                 all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --all')

      expect_command(host.zypper(action_variant,
                                 local: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --local')

      expect_command(host.zypper(action_variant,
                                 remote: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --remote')

      expect_command(host.zypper(action_variant,
                                 medium_type: 'http',
                                 disable: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --disable --medium-type http')

      expect do
        host.zypper(action_variant, medium_type: 'rar')
      end.to raise_error(ArgumentError)

      expect_command(host.zypper(action_variant,
                                 ar_to_enable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --ar-to-enable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')

      expect_command(host.zypper(action_variant,
                                 ar_to_disable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --ar-to-disable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')

      expect_command(host.zypper(action_variant,
                                 rr_to_enable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --rr-to-enable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')

      expect_command(host.zypper(action_variant,
                                 rr_to_disable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --rr-to-disable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')

      expect_command(host.zypper(action_variant,
                                 cl_to_enable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --cl-to-enable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')

      expect_command(host.zypper(action_variant,
                                 cl_to_disable: 'SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev modifyservice --cl-to-disable SMT-http_usanlx_pc_corp_com:SLES11-SP2-pool')
    end
  end

  %w[services ls].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev services --details')
    end
  end

  %w[refresh-services refs].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev refresh-services')

      expect_command(host.zypper(action_variant, force: true, with_repos: true, restore_status: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev refresh-services --force --with-repos --restore-status')
    end
  end

  %w[info if].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, packages: 'workrave'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev info workrave')

      expect_command(host.zypper(action_variant, packages: %w[nginx curl]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev info nginx curl')

      expect_command(host.zypper(action_variant, packages: 'go', type: 'package'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev info -t package go')

      expect_command(host.zypper(action_variant, packages: %w[ffmpeg gcc], repos: 'repo-oss'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev info --repo repo-oss ffmpeg gcc')

      expect_command(host.zypper(action_variant, packages: %w[ffmpeg gcc], repos: %w[repo-oss packman]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev info --repo repo-oss --repo packman ffmpeg gcc')
    end
  end

  %w[install in].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, packages: 'nginx'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install nginx')

      expect_command(host.zypper(action_variant,
                                 packages: %w[nginx curl],
                                 repos: 'repo-oss',
                                 oldpackage: true,
                                 auto_agree_with_licenses: true,
                                 auto_agree_with_product_licenses: true,
                                 replacefiles: true,
                                 dry_run: true,
                                 allow_unsigned_rpm: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install --repo repo-oss --oldpackage --auto-agree-with-licenses --auto-agree-with-product-licenses --replacefiles --dry-run --allow-unsigned-rpm nginx curl')

      expect_command(host.zypper(action_variant,
                                 name: 'nginx',
                                 force: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install -n nginx -f')

      expect_command(host.zypper(action_variant,
                                 name: 'nginx',
                                 force: true,
                                 download_only: true,
                                 download_in_advance: true,
                                 download_in_heaps: true,
                                 download_as_needed: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install -n nginx -f --download-only --download-in-advance --download-in-heaps --download-as-needed')

      expect_command(host.zypper(action_variant,
                                 type: 'srcpackage',
                                 allow_unsigned_rpm: true,
                                 allow_downgrade: true,
                                 allow_name_change: true,
                                 allow_arch_change: true,
                                 allow_vendor_change: true,
                                 debug_solver: true,
                                 force_resolution: true,
                                 solver_focus_mode: 'update',
                                 clean_deps: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install -t srcpackage --allow-unsigned-rpm --debug-solver --force-resolution --solver-focus update --clean-deps --allow-downgrade --allow-name-change --allow-arch-change --allow-vendor-change')

      expect_command(host.zypper(action_variant,
                                 from: 'https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/',
                                 capability: true,
                                 no_force_resolution: true,
                                 no_allow_downgrade: true,
                                 no_allow_name_change: true,
                                 no_allow_arch_change: true,
                                 no_allow_vendor_change: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install --from https://download.opensuse.org/repositories/server:/database/openSUSE_Leap_15.2/ --capability true --no-force-resolution --no-allow-downgrade --no-allow-name-change --no-allow-arch-change --no-allow-vendor-change')
    end
  end

  %w[source-install si].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, packages: 'python-pip', build_deps_only: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev sourceinstall --build-deps-only python-pip')

      expect_command(host.zypper(action_variant,
                                 packages: %w[python-pip i2c-tools],
                                 no_build_deps_only: true,
                                 download_only: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev sourceinstall --download-only python-pip i2c-tools')

      expect_command(host.zypper(action_variant, repos: 'packman', packages: 'bind'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev sourceinstall --repo packman bind')

      expect_command(host.zypper(action_variant, repos: %w[packman repo-oss], packages: %w[bind apache2]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev sourceinstall --repo packman --repo repo-oss bind apache2')
    end
  end

  %w[verify ve].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev verify')

      expect_command(host.zypper(action_variant, dry_run: true, repos: 'repo-oss'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev verify --dry-run --repo repo-oss')

      expect_command(host.zypper(action_variant, dry_run: true, repos: %w[repo-oss packman]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev verify --dry-run --repo repo-oss --repo packman')
    end
  end

  %w[install-new-recommends inr].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install-new-recommends')

      expect_command(host.zypper(action_variant, dry_run: true, repos: 'repo-update'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install-new-recommends --dry-run --repo repo-update')

      expect_command(host.zypper(action_variant, repos: %w[repo-update repo-update-non-oss]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev install-new-recommends --repo repo-update --repo repo-update-non-oss')
    end
  end

  %w[remove rm].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, packages: 'nginx'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev remove nginx')

      expect_command(host.zypper(action_variant,
                                 packages: %w[nginx apache2 curl],
                                 dry_run: true,
                                 capability: true,
                                 repos: %w[packman repo-update repo-oss]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev remove --dry-run --capability --repo packman --repo repo-update --repo repo-oss nginx apache2 curl')
    end
  end

  it 'prepares purge-kernels command' do
    expect_command(host.zypper('purge-kernels'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev purge-kernels')
    expect_command(host.zypper('purge-kernels', dry_run: true),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev purge-kernels --dry-run')
  end

  %w[search se].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant, packages: 'nginx'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev search --details nginx')

      expect_command(host.zypper(action_variant, packages: %w[nginx curl], match_exact: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev search --details --match-exact nginx curl')

      expect_command(host.zypper(action_variant,
                                 packages: %w[nginx curl],
                                 match_substrings: true,
                                 match_words: true,
                                 provides: true,
                                 requires: true,
                                 recommends: true,
                                 suggests: true,
                                 conflicts: true,
                                 obsoletes: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev search --details --match-substrings --match-words --provides --requires --recommends --suggests --conflicts --obsoletes nginx curl')

      expect_command(host.zypper(action_variant,
                                 packages: %w[kernel gcc],
                                 installed_only: true,
                                 sort_by_repo: true,
                                 supplements: true,
                                 provides_pkg: true,
                                 requires_pkg: true,
                                 recommends_pkg: true,
                                 supplements_pkg: true,
                                 conflicts_pkg: true,
                                 obsoletes_pkg: true,
                                 suggests_pkg: true), 'zypper --non-interactive --ignore-unknown --no-color --no-abbrev search --details --supplements --provides-pkg --requires-pkg --recommends-pkg --supplements-pkg --conflicts-pkg --obsoletes-pkg --suggests-pkg --installed-only --sort-by-repo kernel gcc')

      expect_command(host.zypper(action_variant,
                                 packages: %w[kernel gcc],
                                 name: true,
                                 file_list: true,
                                 search_descriptions: true,
                                 case_sensitive: true,
                                 not_installed_only: true,
                                 sort_by_name: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev search --details --name --file-list --search-descriptions --case-sensitive --not-installed-only --sort-by-name kernel gcc')
    end
  end

  %w[clean cc].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev clean')

      expect_command(host.zypper(action_variant, all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev clean --all')

      expect_command(host.zypper(action_variant, repos: 'pacman'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev clean pacman')

      expect_command(host.zypper(action_variant, repos: %w[pacman repo-oss]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev clean pacman repo-oss')

      expect_command(host.zypper(action_variant, metadata: true, raw_metadata: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev clean --metadata --raw-metadata')
    end
  end

  %w[list-updates lu].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-updates')

      expect_command(host.zypper(action_variant,
                                 repos: 'repo-source-non-oss',
                                 type: 'application',
                                 all: true,
                                 best_effort: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-updates --repo repo-source-non-oss -t application --all --best-effort')

      expect_command(host.zypper(action_variant, type: 'patch'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches')
    end
  end

  %w[list-patches lp].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches')

      expect_command(host.zypper(action_variant, bugzilla: '972197'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --bugzilla 972197')

      expect_command(host.zypper(action_variant, cve: 'CVE-2016-2315'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --cve CVE-2016-2315')

      expect_command(host.zypper(action_variant, date: '2021-12-31'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --date 2021-12-31')

      expect_command(host.zypper(action_variant, without_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --without-optional')

      expect_command(host.zypper(action_variant, issues: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --issues')

      expect_command(host.zypper(action_variant, all: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --all')

      expect_command(host.zypper(action_variant, with_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --with-optional')

      expect_command(host.zypper(action_variant, without_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --without-optional')

      expect_command(host.zypper(action_variant, category: 'security'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --category security')

      expect_command(host.zypper(action_variant, category: %w[security recommended optional feature]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --category security --category recommended --category optional --category feature')

      expect_command(host.zypper(action_variant, severity: 'low'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --severity low')

      expect_command(host.zypper(action_variant, severity: %w[critical important moderate]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --severity critical --severity important --severity moderate')

      expect_command(host.zypper(action_variant,
                                 category: %w[security recommended optional feature],
                                 severity: %w[critical important moderate],
                                 repos: %w[packman repo-oss]),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet list-patches --category security --category recommended --category optional --category feature --severity critical --severity important --severity moderate --repo packman --repo repo-oss')
    end
  end

  %w[patch-check pchk].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet patch-check')

      expect_command(host.zypper(action_variant, without_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet patch-check --without-optional')

      expect_command(host.zypper(action_variant, updatestack_only: true, with_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet patch-check --updatestack-only --with-optional')

      expect_command(host.zypper(action_variant, updatestack_only: true, with_optional: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev --quiet patch-check --updatestack-only --with-optional')
    end
  end

  it 'prepares patch command' do
    expect_command(host.zypper('patch'), 'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch')
    expect_command(host.zypper('patch',
                               updatestack_only: true,
                               with_update: true,
                               with_optional: true,
                               replacefiles: true,
                               dry_run: true),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --updatestack-only --with-update --with-optional --replacefiles --dry-run')

    expect_command(host.zypper('patch',
                               auto_agree_with_licenses: true,
                               auto_agree_with_product_licenses: true),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --auto-agree-with-licenses --auto-agree-with-product-licenses')

    expect_command(host.zypper('patch', bugzilla: '972197'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --bugzilla 972197')

    expect_command(host.zypper('patch', cve: 'CVE-2016-2315'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --cve CVE-2016-2315')

    expect_command(host.zypper('patch', date: '2021-12-31'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --date 2021-12-31')

    expect_command(host.zypper('patch', category: 'security'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --category security')

    expect_command(host.zypper('patch', category: %w[security recommended optional feature]),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --category security --category recommended --category optional --category feature')

    expect_command(host.zypper('patch', severity: 'low'),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --severity low')

    expect_command(host.zypper('patch', severity: %w[critical important moderate]),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --severity critical --severity important --severity moderate')

    expect_command(host.zypper('patch',
                               category: %w[security recommended optional feature],
                               severity: %w[critical important moderate],
                               repos: %w[packman repo-oss],
                               debug_solver: true,
                               force_resolution: true,
                               allow_downgrade: true,
                               allow_name_change: true,
                               allow_arch_change: true,
                               allow_vendor_change: true),
                   'zypper --non-interactive --ignore-unknown --no-color --no-abbrev patch --category security --category recommended --category optional --category feature --severity critical --severity important --severity moderate --repo packman --repo repo-oss --debug-solver --force-resolution --allow-downgrade --allow-name-change --allow-arch-change --allow-vendor-change')
  end

  %w[dist-upgrade dup].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev dist-upgrade')

      expect_command(host.zypper(action_variant, dry_run: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev dist-upgrade --dry-run')

      expect_command(host.zypper(action_variant, auto_agree_with_licenses: true, auto_agree_with_product_licenses: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev dist-upgrade --auto-agree-with-licenses --auto-agree-with-product-licenses')

      expect_command(host.zypper(action_variant, dry_run: true, repos: 'pacman'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev dist-upgrade --dry-run --repo pacman')

      expect_command(host.zypper(action_variant,
                                 repos: %w[packman repo-oss],
                                 debug_solver: true,
                                 force_resolution: true,
                                 allow_downgrade: true,
                                 allow_name_change: true,
                                 allow_arch_change: true,
                                 allow_vendor_change: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev dist-upgrade --repo packman --repo repo-oss --debug-solver --force-resolution --allow-downgrade --allow-name-change --allow-arch-change --allow-vendor-change')
    end
  end

  %w[update up].each do |action_variant|
    it "prepares #{action_variant} command" do
      expect_command(host.zypper(action_variant),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev update')

      expect_command(host.zypper(action_variant, repos: 'repo-debug-non-oss', type: 'package'),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev update --repo repo-debug-non-oss -t package')

      expect_command(host.zypper(action_variant,
                                 repos: %w[repo-debug-non-oss repo-non-oss],
                                 replacefiles: true,
                                 best_effort: true,
                                 dry_run: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev update --repo repo-debug-non-oss --repo repo-non-oss --replacefiles --dry-run --best-effort')

      expect_command(host.zypper(action_variant,
                                 debug_solver: true,
                                 force_resolution: true,
                                 allow_downgrade: true,
                                 allow_name_change: true,
                                 allow_arch_change: true,
                                 allow_vendor_change: true),
                     'zypper --non-interactive --ignore-unknown --no-color --no-abbrev update --debug-solver --force-resolution --allow-downgrade --allow-name-change --allow-arch-change --allow-vendor-change')
    end
  end
end
