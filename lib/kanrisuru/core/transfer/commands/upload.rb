module Kanrisuru
  module Core
    module Transfer
      def upload(local_path, remote_path, opts = {})
        tmp_path = "/tmp/kanrisuru-tmp-#{Time.now.to_i}-#{object_id}"

        begin
          result = ssh.scp.upload!(local_path, tmp_path, opts)
          raise 'Unable to upload file' unless result

          result = mv(tmp_path, remote_path)
          raise 'Unable to move file to remote path' unless result.success?

          stat(remote_path)
        ensure
          rm(tmp_path, force: true) if inode?(tmp_path)
        end
      end
    end
  end
end