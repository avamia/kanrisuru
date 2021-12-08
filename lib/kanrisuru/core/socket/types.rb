module Kanrisuru
  module Core
    module Socket
      Statistics = Struct.new(
        :netid, :state, :receive_queue, :send_queue,
        :local_address, :local_port, :peer_address, :peer_port,
        :memory
      )

      StatisticsMemory = Struct.new(
        :rmem_alloc, :rcv_buf, :wmem_alloc, :snd_buf,
        :fwd_alloc, :wmem_queued, :ropt_mem, :back_log, :sock_drop
      )
    end
  end
end
