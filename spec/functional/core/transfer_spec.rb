# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Stat do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'prepares wget command' do
    url = 'https://rubygems.org'

    expect_command(host.wget(url),
                   "wget #{url}")

    ## Output options
    expect_command(host.wget(url,
                             quiet: true, verbose: false, log_file: '/var/log/wget.log'),
                   "wget --quiet --no-verbose --output-file /var/log/wget.log #{url}")

    expect_command(host.wget(url,
                             verbose: true, append_log_file: '/var/log/wget.log'),
                   "wget --verbose --append-output /var/log/wget.log #{url}")

    ## Download options
    expect_command(host.wget(url,
                             bind_address: '0.0.0.0',
                             retries: 3,
                             output_document: '/home/ubuntu/index.html',
                             no_clobber: true,
                             timeout: 30,
                             dns_timeout: 60,
                             connect_timeout: 60,
                             read_timeout: 15,
                             limit_rate: '120k',
                             wait: 5,
                             waitretry: 15,
                             random_wait: true,
                             no_proxy: true,
                             no_dns_cache: true),
                   'wget --bind-address 0.0.0.0 --tries 3 --output-document /home/ubuntu/index.html --no-clobber --timeout 30 --dns-timeout 60 --connect-timeout 60 --read-timeout 15 --limit-rate 120k --wait 5 --waitretry 15 --random-wait --no-proxy --no-dns-cache https://rubygems.org')

    ## Other Options
    expect_command(host.wget(url,
                             quota: 'inf',
                             family: 'inet',
                             restrict_file_names: %w[unix ascii lowercase uppercase],
                             retry_connrefused: true,
                             user: 'admin',
                             password: 'admin',
                             no_iri: true),
                   "wget --quota inf --restrict-file-names unix,ascii,lowercase,uppercase --inet4-only --retry-connrefused --user admin --password admin --no-iri #{url}")

    ## Directories
    expect_command(host.wget(url,
                             no_directories: true,
                             no_host_directories: true,
                             cut_dirs: 3,
                             directory_prefix: '~/downloads/'),
                   "wget --no-directories --no-host-directories --cut-dirs 3 --directory-prefix ~/downloads/ #{url}")

    ## HTTP
    expect_command(host.wget(url,
                             default_page: 'index.html',
                             adjust_extension: true,
                             http_user: 'admin',
                             http_password: 'admin',
                             load_cookies: '~/cookies.txt',
                             save_cookies: '~/cookies.txt',
                             no_cache: true,
                             keep_session_cookies: true,
                             ignore_length: true,
                             headers: {
                               'Accept-Language' => 'hr',
                               'Authorization' => 'Bearer 1234'
                             },
                             max_redirect: 5,
                             proxy_user: 'admin',
                             proxy_password: '12345678'),
                   "wget --default-page index.html --adjust-extension --http-user admin --http-password admin --load-cookies ~/cookies.txt --save-cookies ~/cookies.txt --no-cache --keep-session-cookies --ignore-length --max-redirect 5 --proxy-user admin --proxy-password 12345678 --header 'Accept-Language: hr' --header 'Authorization: Bearer 1234' #{url}")

    expect_command(host.wget(url,
                             post_data: {
                               url: 'https://example.com?param=123'
                             },
                             content_disposition: true,
                             secure_protocol: 'SSLv3',
                             no_check_certificate: true),
                   "wget --post-data url=https%3A%2F%2Fexample.com%3Fparam%3D123 --content-disposition --secure-protocol SSLv3 --no-check-certificate #{url}")

    expect do
      host.wget(url, secure_protocol: 'SSL')
    end.to raise_error(ArgumentError)

    expect_command(host.wget(url,
                             certificate: '~/cert.pem',
                             certificate_type: 'PEM',
                             private_key: '~/key.pem',
                             private_key_type: 'PEM',
                             ca_certificate: '~/ca.pem',
                             random_file: '~/random'),
                   "wget --certificate ~/cert.pem --certificate-type PEM --private-key ~/key.pem --private-key-type PEM --ca-certificate ~/ca.pem --random-file ~/random #{url}")

    expect_command(host.wget(url,
                             certificate: '~/cert.pem',
                             certificate_type: 'PEM',
                             private_key: '~/key.pem',
                             private_key_type: 'PEM',
                             ca_certificate: '~/ca.pem',
                             random_file: '~/random'),
                   "wget --certificate ~/cert.pem --certificate-type PEM --private-key ~/key.pem --private-key-type PEM --ca-certificate ~/ca.pem --random-file ~/random #{url}")

    ## FTP
    expect_command(host.wget(url,
                             ftp_user: 'admin',
                             ftp_password: '12345678',
                             no_remove_listing: true,
                             no_glob: true,
                             no_passive_ftp: true,
                             retr_symlinks: true),
                   "wget --ftp-user admin --ftp-password 12345678 --no-remove-listing --no-glob --no-passive-ftp --retr-symlinks #{url}")

    ## Recursive Retrieval
    expect_command(host.wget(url,
                             recursive: true,
                             depth: 10,
                             delete_after: true,
                             convert_links: true,
                             backup_converted: true,
                             mirror: true,
                             page_requisites: true,
                             strict_comments: true),
                   "wget --recursive --level 10 --delete-after --convert-links --backup-converted --mirror --page-requisites --strict-comments #{url}")

    ## Recursive Accept/Reject
    expect_command(host.wget(url,
                             accept_list: ['.txt', '.html'],
                             reject_list: ['.csv'],
                             domain_list: ['example.com'],
                             exclude_domain_list: ['hackernews.com'],
                             follow_tags: %w[a div span],
                             ignore_tags: %w[area link],
                             include_directories: ['/gems'],
                             exclude_directories: ['/releases'],
                             follow_ftp: true,
                             ignore_case: true,
                             span_hosts: true,
                             relative: true,
                             no_parent: true),
                   "wget --accept .txt,.html --reject .csv --domains example.com --exclude-domains hackernews.com --follow-tags a,div,span --ignore-tags area,link --include-directories /gems --exclude-directories /releases --follow-ftp --ignore-case --span-hosts --relative --no-parent #{url}")
  end
end
