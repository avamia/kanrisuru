# frozen_string_literal: true

module Kanrisuru
  module Core
    module Transfer
      def wget(url, opts = {})
        command = Kanrisuru::Command.new('wget')

        ## Logging and input
        command.append_flag('--quiet', opts[:quiet])

        case opts[:verbose]
        when true
          command.append_flag('--verbose')
        when false
          command.append_flag('--no-verbose')
        end

        command.append_arg('--output-file', opts[:log_file])
        command.append_arg('--append-output', opts[:append_log_file])

        ## Download
        command.append_arg('--bind-address', opts[:bind_address])
        command.append_arg('--tries', opts[:retries])
        command.append_arg('--output-document', opts[:output_document])
        command.append_flag('--no-clobber', opts[:no_clobber])
        command.append_flag('--continue', opts[:continue])
        command.append_flag('--server-response', opts[:server_response])
        command.append_flag('--spider', opts[:spider])
        command.append_arg('--timeout', opts[:timeout])
        command.append_arg('--dns-timeout', opts[:dns_timeout])
        command.append_arg('--connect-timeout', opts[:connect_timeout])
        command.append_arg('--read-timeout', opts[:read_timeout])
        command.append_arg('--limit-rate', opts[:limit_rate])
        command.append_arg('--wait', opts[:wait])
        command.append_arg('--waitretry', opts[:waitretry])
        command.append_flag('--random-wait', opts[:random_wait])
        command.append_flag('--no-proxy', opts[:no_proxy])
        command.append_flag('--no-dns-cache', opts[:no_dns_cache])

        command.append_arg('--quota', opts[:quota])

        if Kanrisuru::Util.present?(opts[:restrict_file_names])
          command.append_arg('--restrict-file-names', Kanrisuru::Util.array_join_string(opts[:restrict_file_names]))
        end

        case opts[:family]
        when 'inet'
          command.append_flag('--inet4-only')
        when 'inet6'
          command.append_flag('--inet6-only')
        end

        command.append_flag('--retry-connrefused', opts[:retry_connrefused])
        command.append_arg('--user', opts[:user])
        command.append_arg('--password', opts[:password])
        command.append_flag('--no-iri', opts[:no_iri])
        command.append_arg('--local-encoding', opts[:local_encoding])
        command.append_arg('--remote-encoding', opts[:remote_encoding])

        ## Directories
        command.append_flag('--no-directories', opts[:no_directories])
        command.append_flag('--force-directories', opts[:force_directories])
        command.append_flag('--no-host-directories', opts[:no_host_directories])
        command.append_flag('--protocol-directories', opts[:protocol_directories])
        command.append_arg('--cut-dirs', opts[:cut_dirs])
        command.append_arg('--directory-prefix', opts[:directory_prefix])

        ## HTTP
        command.append_arg('--default-page', opts[:default_page])
        command.append_flag('--adjust-extension', opts[:adjust_extension])
        command.append_arg('--http-user', opts[:http_user])
        command.append_arg('--http-password', opts[:http_password])
        command.append_arg('--load-cookies', opts[:load_cookies])
        command.append_arg('--save-cookies', opts[:save_cookies])
        command.append_flag('--no-http-keep-alive', opts[:no_http_keep_alive])
        command.append_flag('--no-cache', opts[:no_cache])
        command.append_flag('--no-cookies', opts[:no_cookies])
        command.append_flag('--keep-session-cookies', opts[:keep_session_cookies])
        command.append_flag('--ignore-length', opts[:ignore_length])
        command.append_arg('--max-redirect', opts[:max_redirect])
        command.append_arg('--proxy-user', opts[:proxy_user])
        command.append_arg('--proxy-password', opts[:proxy_password])
        command.append_arg('--referer', opts[:referer])
        command.append_flag('--save-headers', opts[:save_headers])
        command.append_arg('--user-agent', opts[:user_agent])

        headers = opts[:headers]
        if Kanrisuru::Util.present?(headers)
          if headers.instance_of?(Hash)
            headers.each do |key, value|
              header = "'#{key}: #{value}'"
              command.append_arg('--header', header)
            end
          elsif headers.instance_of?(String)
            command.append_arg('--header', headers)
          end
        end

        post_data = opts[:post_data]

        if Kanrisuru::Util.present?(post_data)
          post_data = post_data.instance_of?(Hash) ? URI.encode_www_form(post_data) : post_data
          command.append_arg('--post-data', post_data)
        end

        command.append_arg('--post-file', opts[:post_file])
        command.append_arg('--method', opts[:method])

        command.append_flag('--content-disposition', opts[:content_disposition])
        command.append_flag('--content-on-error', opts[:content_on_error])
        command.append_flag('--trust-server-names', opts[:trust_server_names])
        command.append_flag('--retry-on-host-error', opts[:retry_on_host_error])

        ## SSL / TLS
        if Kanrisuru::Util.present?(opts[:secure_protocol])
          raise ArgumentError, 'invalid ssl protocol' unless WGET_SSL_PROTO.include?(opts[:secure_protocol])

          command.append_arg('--secure-protocol', opts[:secure_protocol])
        end

        command.append_flag('--no-check-certificate', opts[:no_check_certificate])
        command.append_arg('--certificate', opts[:certificate])
        command.append_arg('--certificate-type', opts[:certificate_type])
        command.append_arg('--private-key', opts[:private_key])
        command.append_arg('--private-key-type', opts[:private_key_type])
        command.append_arg('--ca-certificate', opts[:ca_certificate])
        command.append_arg('--ca-directory', opts[:ca_directory])
        command.append_arg('--random-file', opts[:random_file])
        command.append_arg('--egd-file', opts[:egd_file])
        command.append_flag('--https-only', opts[:https_only])

        ## FTP / FTPS
        command.append_arg('--ftp-user', opts[:ftp_user])
        command.append_arg('--ftp-password', opts[:ftp_password])
        command.append_flag('--no-remove-listing', opts[:no_remove_listing])
        command.append_flag('--no-glob', opts[:no_glob])
        command.append_flag('--no-passive-ftp', opts[:no_passive_ftp])
        command.append_flag('--retr-symlinks', opts[:retr_symlinks])
        command.append_flag('--preserve-permissions', opts[:preserve_permissions])
        command.append_flag('--ftps-implicit', opts[:ftps_implicit])
        command.append_flag('--no-ftps-resume-ssl', opts[:no_ftps_resume_ssl])
        command.append_flag('--ftps-clear-data-connection', opts[:ftps_clear_data_connection])
        command.append_flag('--ftps-fallback-to-ftp', opts[:ftps_fallback_to_ftp])

        ## Recursive Retrieval
        command.append_flag('--recursive', opts[:recursive])
        command.append_arg('--level', opts[:level])
        command.append_flag('--delete-after', opts[:delete_after])
        command.append_flag('--convert-links', opts[:convert_links])
        command.append_flag('--backup-converted', opts[:backup_converted])
        command.append_flag('--mirror', opts[:mirror])
        command.append_flag('--page-requisites', opts[:page_requisites])
        command.append_flag('--strict-comments', opts[:strict_comments])

        ## Recursive Accept/Reject
        command.append_arg('--accept', Kanrisuru::Util.array_join_string(opts[:accept]))
        command.append_arg('--reject', Kanrisuru::Util.array_join_string(opts[:reject]))
        command.append_arg('--accept-regex', opts[:accept_regex])
        command.append_arg('--reject-regex', opts[:reject_regex])
        command.append_arg('--regex_type', opts[:regex_type])
        command.append_arg('--domains', Kanrisuru::Util.array_join_string(opts[:domains]))
        command.append_arg('--exclude-domains', Kanrisuru::Util.array_join_string(opts[:exclude_domains]))
        command.append_arg('--follow-tags', Kanrisuru::Util.array_join_string(opts[:follow_tags]))
        command.append_arg('--ignore-tags', Kanrisuru::Util.array_join_string(opts[:ignore_tags]))
        command.append_arg('--include-directories', Kanrisuru::Util.array_join_string(opts[:include_directories]))
        command.append_arg('--exclude-directories', Kanrisuru::Util.array_join_string(opts[:exclude_directories]))
        command.append_flag('--follow-ftp', opts[:follow_ftp])
        command.append_flag('--ignore-case', opts[:ignore_case])
        command.append_flag('--span-hosts', opts[:span_hosts])
        command.append_flag('--relative', opts[:relative])
        command.append_flag('--no-parent', opts[:no_parent])

        command << url

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
