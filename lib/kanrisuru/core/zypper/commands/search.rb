# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_search(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'search'

        command.append_flag('--details')
        command.append_flag('--match-substrings', opts[:match_substrings])
        command.append_flag('--match-words', opts[:match_words])
        command.append_flag('--match-exact', opts[:match_exact])
        command.append_flag('--provides', opts[:provides])
        command.append_flag('--requires', opts[:requires])
        command.append_flag('--recommends', opts[:recommends])
        command.append_flag('--suggests', opts[:suggests])
        command.append_flag('--conflicts', opts[:conflicts])
        command.append_flag('--obsoletes', opts[:obsoletes])
        command.append_flag('--supplements', opts[:supplements])
        command.append_flag('--provides-pkg', opts[:provides_pkg])
        command.append_flag('--requires-pkg', opts[:requires_pkg])
        command.append_flag('--recommends-pkg', opts[:recommends_pkg])
        command.append_flag('--supplements-pkg', opts[:supplements_pkg])
        command.append_flag('--conflicts-pkg', opts[:conflicts_pkg])
        command.append_flag('--obsoletes-pkg', opts[:obsoletes_pkg])
        command.append_flag('--suggests-pkg', opts[:suggests_pkg])
        command.append_flag('--name', opts[:name])
        command.append_flag('--file-list', opts[:file_list])
        command.append_flag('--search-descriptions', opts[:search_descriptions])
        command.append_flag('--case-sensitive', opts[:case_sensitive])
        command.append_flag('--installed-only', opts[:installed_only])
        command.append_flag('--not-installed-only', opts[:not_installed_only])
        command.append_flag('--sort-by-name', opts[:sort_by_name])
        command.append_flag('--sort-by-repo', opts[:sort_by_repo])

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)
        command.append_array(opts[:packages])

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Search.parse(cmd)
        end
      end
    end
  end
end
