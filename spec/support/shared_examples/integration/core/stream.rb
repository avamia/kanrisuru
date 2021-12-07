# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'stream' do |os_name, host_json, spec_dir|
  context "with #{os_name}" do
    before(:all) do
      host = Kanrisuru::Remote::Host.new(
        host: host_json['hostname'],
        username: host_json['username'],
        keys: [host_json['ssh_key']]
      )

      host.mkdir(spec_dir, silent: true)
      host.disconnect
    end

    let(:host) do
      Kanrisuru::Remote::Host.new(
        host: host_json['hostname'],
        username: host_json['username'],
        keys: [host_json['ssh_key']]
      )
    end

    after do
      host.disconnect
    end

    after(:all) do
      host = Kanrisuru::Remote::Host.new(
        host: host_json['hostname'],
        username: host_json['username'],
        keys: [host_json['ssh_key']]
      )

      host.rmdir(spec_dir)
      host.disconnect
    end

    it 'outputs beginning of a file' do
      file = host.file("#{spec_dir}/test-file.txt")
      file.touch
      file.append do |f|
        f << 'This'
        f << 'is'
        f << 'a'
        f << 'file!'
      end

      result = host.head("#{spec_dir}/test-file.txt", lines: 2)
      expect(result).to be_success
      expect(result.data.length).to eq(2)
      expect(result.data).to eq(%w[This is])
    end

    it 'outputs end of a file' do
      file = host.file("#{spec_dir}/test-file.txt")
      file.touch
      file.append do |f|
        f << 'This'
        f << 'is'
        f << 'a'
        f << 'file!'
      end

      result = host.tail("#{spec_dir}/test-file.txt", lines: 2)
      expect(result).to be_success
      expect(result.data.length).to eq(2)
      expect(result.data).to eq(['a', 'file!'])
    end

    it 'reads a chunk of text from a file' do
      file = host.file("#{spec_dir}/test-file-chunk.txt")
      file.touch
      file.append do |f|
        f << 'This'
        f << 'is'
        f << 'is'
        f << 'a'
        f << 'file'
        f << 'forever...'
      end

      result = host.read_file_chunk("#{spec_dir}/test-file-chunk.txt", 2, 4)
      expect(result).to be_success
      expect(result.data.length).to eq(3)
      expect(result.data).to eq(%w[is is a])
    end

    it 'cats a file' do
      result = host.cat('/etc/group')
      expect(result.success?).to eq(true)
      expect(result.data.include?('root:x:0:')).to eq(true)
    end

    it 'echoes to stdout' do
      result = host.echo('Hello world')
      expect(result.data).to eq('Hello world')
    end

    it 'seds file to stdout' do
      path = "#{spec_dir}/test-file.txt"
      result = host.echo("Hello world, this is a Cat test file.\nCat\nCat\nDog", new_file: path, mode: 'write')
      expect(result).to be_success

      result = host.sed(path, 'Cat', 'Dog')
      expect(result).to be_success
      expect(result.data).to eq("Hello world, this is a Dog test file.\nDog\nDog\nDog")
    end
  end
end
