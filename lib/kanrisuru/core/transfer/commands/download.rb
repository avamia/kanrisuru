# frozen_string_literal: true

module Kanrisuru
  module Core
    module Transfer
      def download(remote_path, local_path = nil, opts = {})
        recursive = opts[:recursive] || false

        remote_path += '/' if !remote_path.end_with?('/') && recursive
        local_path += '/' if !local_path.nil? && !local_path.end_with?('/') && recursive

        if local_path.instance_of?(Hash)
          opts = local_path
          local_path = nil
        end

        tmp_name = "kanrisuru-tmp-#{Time.now.to_i}-#{object_id}"
        tmp_path = "/tmp/#{tmp_name}"

        begin
          result = cp(remote_path, tmp_path, force: true, follow: true, recursive: recursive)
          raise 'Unable to copy remote file to temp path' unless result.success?

          result = chown(tmp_path, owner: @username, group: @username, recursive: recursive)
          raise 'Unable to update owner or group for temp path' unless result.success?

          result = chmod(tmp_path, 'u+r', recursive: true)
          raise 'Unable to update owner permission read access' unless result.success?

          local_path = ::File.expand_path(local_path) if local_path
          result = ssh.scp.download!(tmp_path, local_path, opts)
          return false unless result

          if Kanrisuru::Util.present?(local_path) && recursive
            remote_dirname = remote_path.split('/').last
            FileUtils.mv("#{local_path}/#{tmp_name}", "#{local_path}/#{remote_dirname}")
          else
            result
          end
        ensure
          rm(tmp_path, force: true, recursive: recursive) if inode?(tmp_path)
        end
      end
    end
  end
end
