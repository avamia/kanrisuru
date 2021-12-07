# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'archive' do |os_name, host_json, spec_dir|
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
      host.rmdir("#{spec_dir}/extract-tar-files") if host.dir?("#{spec_dir}/extract-tar-files")
      host.disconnect
    end

    it 'tars an archive' do
      archive = 'archive.tar'
      archive2 = 'archive2.tar'
      directory = spec_dir

      host.touch("#{spec_dir}/test-file.txt")
      host.touch("#{spec_dir}/test1.txt")
      host.touch("#{spec_dir}/test2.txt")
      host.touch("#{spec_dir}/test3.txt")

      host.touch("#{spec_dir}/test1.config")
      host.touch("#{spec_dir}/test2.config")
      host.touch("#{spec_dir}/test3.config")

      host.cd(spec_dir)
      result = host.tar('create', archive, paths: ['*.txt'], exclude: 'test-file.txt', directory: directory)

      expect(result.success?).to eq(true)

      file = host.file("#{spec_dir}/#{archive}")

      expect(file.path).to eq("#{spec_dir}/archive.tar")
      expect(file.user).to eq(host_json['username'])

      case os_name
      when 'opensuse', 'sles'
        expect(file.group).to eq('users')
      else
        expect(file.group).to eq(host_json['username'])
      end

      result = host.tar('list', archive, directory: directory)
      expect(result.success?).to eq(true)
      paths = result.map(&:path)
      expect(paths.include?('test-file.txt')).to eq(false)

      result = host.tar('append', archive, paths: 'test-file.txt', directory: directory)
      expect(result.success?).to eq(true)

      result = host.tar('list', archive, directory: directory)
      paths = result.map(&:path)

      expect(paths.include?('test-file.txt')).to eq(true)

      result = host.tar('create', archive2, paths: '*.config', directory: directory)
      expect(result.success?).to eq(true)

      file = host.file("#{spec_dir}/#{archive2}")

      expect(file.path).to eq("#{spec_dir}/archive2.tar")
      expect(file.user).to eq(host_json['username'])

      case os_name
      when 'opensuse', 'sles'
        expect(file.group).to eq('users')
      else
        expect(file.group).to eq(host_json['username'])
      end

      result = host.tar('concat', archive, paths: archive2, directory: directory)
      expect(result.success?).to eq(true)

      result = host.tar('list', archive, directory: directory)
      expect(result.success?).to eq(true)
      paths = result.map(&:path)

      expect(paths.include?('test1.config')).to eq(true)
      expect(paths.include?('test2.config')).to eq(true)
      expect(paths.include?('test3.config')).to eq(true)

      result = host.tar('diff', archive, directory: directory)
      expect(result.success?).to eq(true)

      result = host.tar('delete', archive, directory: directory, paths: 'test2.config')
      expect(result.success?).to eq(true)

      result = host.tar('list', archive, directory: directory)
      expect(result.success?).to eq(true)
      paths = result.map(&:path)
      expect(paths.include?('test2.config')).to eq(false)

      host.mkdir("#{spec_dir}/extract-tar-files", silent: true)
      host.tar('extract', 'archive.tar', directory: "#{spec_dir}/extract-tar-files")

      result = host.ls(path: "#{spec_dir}/extract-tar-files")
      paths = result.map(&:path)

      expect(paths.include?('test1.config')).to eq(true)
      expect(paths.include?('test3.config')).to eq(true)
      expect(paths.include?('test-file.txt')).to eq(true)
      expect(paths.include?('test1.txt')).to eq(true)
      expect(paths.include?('test2.txt')).to eq(true)
      expect(paths.include?('test3.txt')).to eq(true)
    end

    it 'compresses archive while tar' do
      archive = 'archive.tar'
      directory = spec_dir

      host.touch("#{spec_dir}/test1.log")
      host.touch("#{spec_dir}/test2.log")
      host.touch("#{spec_dir}/test3.log")

      host.cd(spec_dir)
      result = host.tar('create', "#{archive}.gz", compress: 'gzip', paths: ['*.log'], directory: directory)
      expect(result.success?).to eq(true)

      file = host.file("#{spec_dir}/#{archive}.gz")
      expect(file.path).to eq("#{spec_dir}/archive.tar.gz")
      expect(file.uid).to eq(1000)

      case os_name
      when 'opensuse', 'sles'
        expect(file.gid).to eq(100)
      else
        expect(file.gid).to eq(1000)
      end

      case os_name
      when 'debian', 'ubuntu'
        result = host.tar('create', "#{archive}.bz", compress: 'bzip2', paths: ['*.log'], directory: directory)
        expect(result.success?).to eq(true)

        file = host.file("#{spec_dir}/#{archive}.bz")
        expect(file.path).to eq("#{spec_dir}/archive.tar.bz")
        expect(file.uid).to eq(1000)
        expect(file.gid).to eq(1000)
      end

      # case os_name
      # when 'opensuse', 'sles'
      #   expect(file.gid).to eq(100)
      # else
      # end

      case os_name
      when 'debian'
        ## no op
      else
        result = host.tar('create', "#{archive}.xz", compress: 'xz', paths: ['*.log'], directory: directory)
        expect(result.success?).to eq(true)

        file = host.file("#{spec_dir}/#{archive}.xz")
        expect(file.path).to eq("#{spec_dir}/archive.tar.xz")
        expect(file.uid).to eq(1000)

        case os_name
        when 'opensuse', 'sles'
          expect(file.gid).to eq(100)
        else
          expect(file.gid).to eq(1000)
        end
      end

      case os_name
      when 'centos', 'rhel', 'debian'
        ## no op
      else
        result = host.tar('create', "#{archive}.lzma", compress: 'lzma', paths: ['*.log'], directory: directory)
        expect(result.success?).to eq(true)

        file = host.file("#{spec_dir}/#{archive}.lzma")
        expect(file.path).to eq("#{spec_dir}/archive.tar.lzma")
        expect(file.uid).to eq(1000)

        case os_name
        when 'opensuse', 'sles'
          expect(file.gid).to eq(100)
        else
          expect(file.gid).to eq(1000)
        end
      end

      expect do
        host.tar('create', "#{archive}.lzop", compress: 'lzop', paths: ['*.log'],
                                              directory: directory)
      end.to raise_error(ArgumentError)
    end
  end
end
