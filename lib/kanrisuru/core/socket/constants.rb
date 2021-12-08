# frozen_string_literal: true

module Kanrisuru
  module Core
    module Socket
      TCP_STATES = %w[
        established syn-sent syn-recv
        fin-wait-1 fin-wait-2 time-wait
        closed close-wait last-ack listening closing
      ].freeze

      OTHER_STATES = %w[
        all connected synchronized bucket syn-recv
        big
      ].freeze

      TCP_STATE_ABBR = {
        'ESTAB' => 'established', 'LISTEN' => 'listening', 'UNCONN' => 'unconnected',
        'SYN-SENT' => 'syn-sent', 'SYN-RECV' => 'syn-recv', 'FIN-WAIT-1' => 'fin-wait-1',
        'FIN-WAIT-2' => 'fin-wait-2', 'TIME-WAIT' => 'time-wait', 'CLOSE-WAIT' => 'close-wait',
        'LAST-ACK' => 'last-ack', 'CLOSING' => 'closing'
      }.freeze

      NETWORK_FAMILIES = %w[
        unix inet inet6 link netlink
      ].freeze
    end
  end
end
