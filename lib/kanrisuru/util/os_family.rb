# frozen_string_literal: true

module Kanrisuru
  class Util
    class OsFamily
      @os_dict = {
        unix: {
          name: 'UNIX',
          os_family: 'unix',
          model: 'open_source',
          type: 'abstract'
        },
        unix_like: {
          name: 'unix-like',
          os_family: 'unix',
          type: 'abstract'
        },
        bsd: {
          name: 'BSD',
          os_family: 'unix',
          upstream: 'unix',
          model: 'open_source',
          state: 'discontinued',
          type: 'distribution'
        },
        solaris: {
          name: 'Solaris',
          os_family: 'unix',
          upstream: 'bsd',
          model: 'mixed',
          state: 'current',
          type: 'distribution'
        },
        free_bsd: {
          name: 'FreeBSD',
          os_family: 'unix_like',
          upstream: 'bsd',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        dragon_fly_bsd: {
          name: 'DragonFly BSD',
          os_family: 'unix_like',
          upstream: 'free_bsd',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        net_bsd: {
          name: 'NetBSD',
          os_family: 'unix_like',
          upstream: 'bsd',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        open_bsd: {
          name: 'OpenBSD',
          os_family: 'unix_like',
          upstream: 'net_bsd',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        darwin: {
          name: 'Darwin',
          os_family: 'unix_like',
          upstream: 'free_bsd',
          model: 'open_source',
          state: 'current',
          type: 'kernel'
        },
        pure_darwin: {
          name: 'Pure Darwin',
          os_family: 'darwin',
          upstream: 'darwin',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        mac_os: {
          name: 'MacOS',
          os_family: 'darwin',
          upstream: 'darwin',
          model: 'closed_source',
          state: 'current',
          type: 'distribution'
        },
        mac: {
          name: 'Mac',
          type: 'alias',
          to: 'mac_os'
        },
        mac_osx: {
          name: 'MacOSX',
          type: 'alias',
          to: 'mac_os'
        },
        linux: {
          name: 'GNU/Linux',
          os_family: 'unix_like',
          upstream: 'unix',
          model: 'open_source',
          state: 'current',
          type: 'kernel'
        },
        debian: {
          name: 'Debian',
          os_family: 'linux',
          upstream: 'linux',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        ubuntu: {
          name: 'Ubuntu',
          os_family: 'linux',
          upstream: 'debian',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        linux_mint: {
          name: 'Linux Mint',
          os_family: 'linux',
          upstream: 'ubuntu',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        fedora: {
          name: 'Fedora',
          os_family: 'linux',
          upstream: 'linux',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        redhat: {
          name: 'RHEL',
          os_family: 'linux',
          upstream: 'fedora',
          model: 'commercial',
          state: 'current',
          type: 'distribution'
        },
        rhel: {
          name: 'RHEL',
          type: 'alias',
          to: 'redhat'
        },
        centos: {
          name: 'CentOS',
          type: 'alias',
          to: 'cent_os'
        },
        cent_os: {
          name: 'CentOS',
          os_family: 'linux',
          upstream: 'redhat',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        opensuse: {
          name: 'openSUSE',
          os_family: 'linux',
          upstream: 'linux',
          model: 'open_source',
          state: 'current',
          type: 'distribution'
        },
        opensuse_leap: {
          name: 'openSUSE Leap',
          type: 'alias',
          to: 'opensuse'
        },
        sles: {
          name: 'SUSE Linux Enterprise Server',
          os_family: 'linux',
          upstream: 'opensuse',
          model: 'commercial',
          state: 'current',
          type: 'distribution'
        }
      }

      def self.family_include_distribution?(family, dist)
        if OsFamily[dist].nil?
          false
        elsif OsFamily[dist][:type] == 'alias'
          family_include_distribution?(family, OsFamily[dist][:to])
        elsif OsFamily[dist][:os_family] == family
          true
        else
          family_include_distribution?(family, OsFamily[dist][:upstream])
        end
      end

      def self.upstream_include_distribution?(upstream, dist)
        if OsFamily[dist].nil?
          false
        elsif OsFamily[dist][:type] == 'alias'
          upstream_include_distribution?(upstream, OsFamily[dist][:to])
        elsif OsFamily[dist][:upstream] == upstream && OsFamily[dist][:type] == 'distribution'
          true
        else
          upstream_include_distribution?(upstream, OsFamily[dist][:upstream])
        end
      end

      def self.[](name)
        @os_dict[name.to_sym] if !name.nil? && @os_dict.include?(name.to_sym)
      end
    end
  end
end
