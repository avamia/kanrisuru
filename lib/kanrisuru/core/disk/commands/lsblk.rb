# frozen_string_literal: true

module Kanrisuru
  module Core
    module Disk
      def lsblk(opts = {})
        all    = opts[:all]
        nodeps = opts[:nodeps]
        paths  = opts[:paths]

        command = Kanrisuru::Command.new('lsblk')

        version = lsblk_version.to_f

        ## lsblk after version 2.26 handles json parsing.
        ## TODO: parse nested children for earlier version of lsblk
        if version >= LSBK_VERSION
          command.append_flag('--json') if version >= LSBK_VERSION
        else
          command.append_flag('-i')
          command.append_flag('-P')
          command.append_flag('--noheadings')
        end

        command.append_flag('-a', all)
        command.append_flag('-p', paths)
        command.append_flag('-d', nodeps)

        command.append_arg('-o', 'NAME,FSTYPE,MAJ:MIN,MOUNTPOINT,SIZE,UUID,RO,RM,OWNER,GROUP,MODE,TYPE')
        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Lsblk.parse(cmd, version)
        end
      end

      private

      def lsblk_version
        command = Kanrisuru::Command.new('lsblk --version')
        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::LsblkVersion.parse(cmd)
        end
      end
    end
  end
end
