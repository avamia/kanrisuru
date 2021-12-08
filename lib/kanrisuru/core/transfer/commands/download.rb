module Kanrisuru
  module Core
    module Transfer
      def download(remote_path, local_path = nil, opts = {})
        if local_path.instance_of?(Hash)
          opts = local_path
          local_path = nil
        end

        tmp_path = "/tmp/kanrisuru-tmp-#{Time.now.to_i}-#{object_id}"

        begin
          result = cp(remote_path, tmp_path, force: true)
          raise 'Unable to copy remote file to temp path' unless result.success?

          result = ssh.scp.download!(tmp_path, local_path, opts)
          Kanrisuru::Util.blank?(local_path) ? result : local_path
        ensure
          rm(tmp_path, force: true) if inode?(tmp_path)
        end
      end
    end
  end
end
