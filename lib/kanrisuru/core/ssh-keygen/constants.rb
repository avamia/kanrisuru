# frozen_string_literal: true

module Kanrisuru
  module Core
    module SSHKeygen
      KEY_TYPES = %w[dsa ecdsa ecdsa-sk ed25519 ed25519-sk rsa].freeze
      FINGERPRINT_HASHES = %w[md5 sha256].freeze

    end
  end
end
