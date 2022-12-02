# frozen_string_literal: true

#--
# Copyright (c) 2020-2022 Avamia, LLC
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require_relative 'kanrisuru/version'
require_relative 'kanrisuru/logger'
require_relative 'kanrisuru/util'
require_relative 'kanrisuru/mode'
require_relative 'kanrisuru/os_package'
require_relative 'kanrisuru/command'
require_relative 'kanrisuru/processor_count'
require_relative 'kanrisuru/local'
require_relative 'kanrisuru/remote'
require_relative 'kanrisuru/result'
require_relative 'kanrisuru/core'
require_relative 'kanrisuru/template'

module Kanrisuru
  def self.logger
    @logger ||= Kanrisuru::Logger.new($stdout, formatter: proc { |severity, _datetime, _progname, msg|
      "#{severity}: #{msg}\n"
    })
  end

  class Error < StandardError; end
end
