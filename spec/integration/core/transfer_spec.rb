# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::File do
  TestHosts.each_os do |os_name|
    context "with #{os_name}" do
      before(:all) do
        host_json = TestHosts.host(os_name)
        host = Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )

        host.mkdir("#{host_json['home']}/.kanrisuru_spec_files", silent: true)
        host.disconnect
      end

      let(:host_json) { TestHosts.host(os_name) }
      let(:host) do
        Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )
      end

      let(:spec_dir) { "#{host_json['home']}/.kanrisuru_spec_files" }

      after do
        host.disconnect
      end

      after(:all) do
        host_json = TestHosts.host(os_name)
        host = Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )

        host.rmdir("#{host_json['home']}/.kanrisuru_spec_files")
        host.disconnect
      end

      it 'uploads a template file' do
        path = '../templates/test.conf.erb'
        dest_path = "#{spec_dir}/test.conf"

        template = Kanrisuru::Template.new(path, array: %w[this is an array])
        result = host.upload(template.read, dest_path)

        expect(result).to be_success
        expect(result.mode.numeric).to eq('640')
        expect(result.user).to eq(host_json['username'])

        case os_name
        when 'sles', 'opensuse'
          expect(result.gid).to eq(100)
          expect(result.group).to eq('users')
        else
          expect(result.gid).to eq(1000)
          expect(result.group).to eq(host_json['username'])
        end

        expect(host.cat(dest_path).to_a).to eq([
                                                 '<h1>Hello World</h1>',
                                                 'this',
                                                 'is',
                                                 'an',
                                                 'array'
                                               ])
      end

      it 'uploads a dir' do
        path = '../meta/'
        dest_path = "#{spec_dir}/meta"

        result = host.upload(path, dest_path, recursive: true)
        expect(result).to be_success
      end

      it 'downloads a file to local fs' do
        path = '../hosts-file'
        src_path = '/etc/hosts'

        result = host.download(src_path, path)
        expect(result).to eq(path)
        FileUtils.rm(path)
      end

      it 'downloads a file directly' do
        src_path = '/etc/hosts'

        result = host.download(src_path)
        expect(result).to be_instance_of(String)
        lines = result.split("\n")
        expect(lines.length).to be >= 1
      end

      it 'wgets url' do
        result = host.wget('https://example.com', directory_prefix: spec_dir)
        expect(result).to be_success
      end
    end
  end
end
