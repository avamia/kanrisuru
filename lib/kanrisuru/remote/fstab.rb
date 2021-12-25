# frozen_string_literal: true

require_relative 'fstab/entry'
require_relative 'fstab/options'

module Kanrisuru
  module Remote
    class Fstab
      include Enumerable

      def initialize(host, path = '/etc/fstab')
        @host = host
        @path = path
        @file = nil
        @backup = nil

        init_from_os
      end

      def [](device)
        get_entry(device)
      end

      def get_entry(device)
        result = @entries[device]

        return result[:entry] if result

        result = nil

        ## Lookup by uuid or label
        @entries.each do |_, entry|
          result = entry[:entry] if !@result && (entry[:entry].uuid == device || entry[:entry].label == device)
        end

        result
      end

      def <<(entry)
        append(entry)
      end

      def append(entry)
        if entry.instance_of?(Kanrisuru::Remote::Fstab::Entry)
          return if @entries.key?(entry.device)
        elsif entry.instance_of?(String)
          entry = Kanrisuru::Remote::Fstab::Entry.new(host: @host, line: entry)
          return if @entries.key?(entry.device)
        else
          raise ArgumentError, 'Invalid entry type'
        end

        @entries[entry.device] = {
          entry: entry,
          new: true
        }

        nil
      end

      def find_device(device); end

      def each(&block)
        @entries.each do |_, entry|
          block.call(entry[:entry])
        end
      end

      ## Only append new entries to file
      def append_file!
        @file.append do |f|
          @entries.each do |_, entry|
            f << entry[:entry].to_s if entry[:new]
          end
        end

        reload!
      end

      ## Rewrites entire fstab file with new and old entries
      def write_file!
        @file.write do |f|
          @entries.each do |_, entry|
            f << entry[:entry].to_s
          end
        end

        reload!
      end

      def to_s
        lines = []
        @entries.each do |_, entry|
          lines << entry[:entry].to_s
        end

        lines.join("\n")
      end

      def reload!
        init_from_os
      end

      def inspect
        format('#<Kanrisuru::Remote::Fstab:0x%<object_id>s @path=%<path>s @entries=%<entries>s>',
               object_id: object_id, path: @path, entries: @entries)
      end

      private

      def init_from_os
        @entries = {}

        raise 'Not implemented' unless @host.os && @host.os.kernel == 'Linux'

        initialize_linux
      end

      def initialize_linux
        if @file
          @file.reload!
        else
          @file = @host.file(@path)
        end

        raise ArgumentError, 'Invalid file' if !@file.exists? || !@file.file?

        @file.each do |line|
          next if line.strip.chomp.empty?
          next if line =~ /\s*#/

          entry = Fstab::Entry.new(host: @host, line: line)
          @entries[entry.device] = {
            entry: entry,
            new: false
          }
        end
      end
    end
  end
end
