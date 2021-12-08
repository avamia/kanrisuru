# frozen_string_literal: true

require_relative 'stream/parser'
require_relative 'stream/commands'

module Kanrisuru
  module Core
    module Stream
      extend OsPackage::Define

      os_define :linux, :head
      os_define :linux, :tail
      os_define :linux, :read_file_chunk
      os_define :linux, :sed
      os_define :linux, :echo
      os_define :linux, :cat
    end
  end
end
