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
        host.rmdir("#{host_json['home']}/extract-tar-files") if host.dir?("#{host_json['home']}/extract-tar-files")
        host.disconnect
      end

      it 'changes file permission flags' do
        host.su('root')

        path = "#{spec_dir}/test.txt"
        host.touch(path)

        mode = host.stat(path).mode

        expect(mode).to be_instance_of(Kanrisuru::Mode)

        mode.numeric = 0o777

        mode = host.chmod(path, mode).mode

        expect(mode).to be_instance_of(Kanrisuru::Mode)
        expect(mode.numeric).to eq('777')

        mode.symbolic = 'g=r,o=r'

        mode = host.chmod(path, mode).mode
        expect(mode.symbolic).to eq('-rwxr--r--')
        expect(mode.to_i).to eq(0o744)

        expect {
          host.chmod(path, 600)
        }.to raise_error(ArgumentError)
      end

      it 'changes file owner and group' do
        path = "#{spec_dir}/test-owner.txt"

        host.touch(path)

        host.su('root')
        result = host.chown(path, owner: host_json['username'], group: host_json['username'])

        expect(result.user).to eq(host_json['username'])
        expect(result.uid).to eq(1000)

        case os_name
        when 'opensuse', 'sles'
          expect(result.group).to eq('users')
          expect(result.gid).to eq(100)
        else
          expect(result.group).to eq(host_json['username'])
          expect(result.gid).to eq(1000)
        end

        host.su('root')
        result = host.chown(path, owner: 'root', group: 'root')

        expect(result.user).to eq('root')
        expect(result.uid).to eq(0)
        expect(result.group).to eq('root')
        expect(result.gid).to eq(0)
      end

      it 'touches files' do
        result = host.touch("#{spec_dir}/test-date.txt", date: '2021-01-01')

        expect(result.success?).to eq(true)
        expect(result[0].last_modified).to be_instance_of(DateTime)
        expect(result[0].last_modified.to_date.to_s).to eq('2021-01-01')

        paths = ["#{spec_dir}/test1.config", "#{spec_dir}/test2.config", "#{spec_dir}/test3.config"]
        host.touch(paths)

        realpaths = paths.map do |path|
          host.realpath(path).path
        end

        result = host.touch(paths)
        expect(result.data).to be_instance_of(Array)

        current_date = Time.now.to_date.to_s

        result.each do |item|
          expect(realpaths.include?(item.path)).to eq(true)
          expect(item.user).to eq(host_json['username'])
          expect(item.fsize).to eq(0)
          expect(item.last_modified.to_date.to_s).to eq(current_date)
          expect(item.last_access.to_date.to_s).to eq(current_date)
          expect(item.last_changed.to_date.to_s).to eq(current_date)
        end
      end

      it 'soft links file' do
        path = "#{spec_dir}/test-file.txt"

        result_a = host.touch(path)[0]
        expect(result_a.path).to eq(host.realpath(path).path)

        result_b = host.symlink(path, "#{spec_dir}/test-symlink.txt")

        expect(host.realpath(result_b.path).path).to eq(result_a.path)
        expect(result_b.file_type).to eq('symbolic link')
      end

      it 'hard links file' do
        path = "#{spec_dir}/test-file-ln.txt"
        host.touch(path)

        result_a = host.touch(path)[0]
        result_b = host.link(path, "#{spec_dir}/test-link.txt")

        expect(result_b.inode).to eq(result_a.inode)
        expect(result_b.file_type).to eq('regular empty file')

        result = host.find(inode: result_a.inode)
        files = result.map do |item|
          host.realpath(item.path).path
        end

        expect(files.include?(host.realpath(result_a.path).path)).to eq(true)
        expect(files.include?(host.realpath(result_b.path).path)).to eq(true)

        ## Can't hard link dir
        expect(host.link(spec_dir.to_s, "#{spec_dir}/tmpb")).to eq(false)

        host.rm("#{spec_dir}/test-link.txt")
      end

      it 'creates directory' do
        path = "#{spec_dir}/test-dir/"
        result = host.mkdir(path)

        expect(result).to be_success
        expect(result.path).to eq(path)
        expect(result.mode.numeric).to eq('755')
        expect(result.file_type).to eq('directory')
        expect(result.uid).to eq(1000)
        expect(result.user).to eq(host_json['username'])

        case os_name
        when 'sles', 'opensuse'
          expect(result.gid).to eq(100)
          expect(result.group).to eq('users')
        else
          expect(result.gid).to eq(1000)
          expect(result.group).to eq(host_json['username'])
        end

        result = host.ls(path: spec_dir)
        expect(result.success?).to eq(true)
        selected = result.find { |item| item.path == 'test-dir' }

        expect(selected.path).to eq('test-dir')
      end

      it 'copies a file' do
        path = "#{spec_dir}/remote-file.txt"
        copied_path = "#{spec_dir}/remote-file-copied.txt"

        file = host.file(path)
        file.touch
        file.append do |f|
          f << 'Hello'
          f << 'World'
        end

        result = host.cp(path, copied_path)
        expect(result.success?).to eq(true)

        result = host.cat(copied_path)
        expect(result.success?).to eq(true)
        expect(result.data).to eq(%w[Hello World])
      end

      it 'copies directories' do
        path = "#{spec_dir}/remote-dir"
        subdir_path = "#{path}/subdir"
        copied_path = "#{spec_dir}/copied-dir"

        result = host.mkdir(path)
        expect(result.success?).to eq(true)

        result = host.mkdir(subdir_path)
        expect(result.success?).to eq(true)

        file = host.file("#{subdir_path}/test-nested.txt")
        file.touch
        file.append do |f|
          f << 'This is a'
          f << 'test file...'
        end

        result = host.cp(path, copied_path, recursive: true)
        expect(result.success?).to eq(true)
      end

      it 'copies with a backup' do
        path = "#{spec_dir}/remote-file-to-backup.txt"
        copied_path = "#{spec_dir}/remote-file-copied-with-backup.txt"

        file = host.file(path)
        file.touch
        file.append do |f|
          f << 'Hello'
          f << 'World'
        end

        result = host.cp(path, copied_path)
        expect(result).to be_success

        file.append do |f|
          f << 'New Content'
        end

        result = host.cp(path, copied_path, backup: true)
        expect(result.success?).to eq(true)

        result = host.ls(path: spec_dir)
        backup = result.find { |f| f.path == 'remote-file-copied-with-backup.txt~' }
        expect(backup.path).to eq('remote-file-copied-with-backup.txt~')
      end

      it 'moves files' do
        path = "#{spec_dir}/remote-file-to-move.txt"
        new_path = "#{spec_dir}/remote-file-moved.txt"

        file = host.file(path)
        file.touch
        file.append do |f|
          f << 'Hello'
          f << 'World'
        end

        result = host.mv(path, new_path, no_target_directory: true)
        expect(result.success?).to eq(true)

        result = host.cat(new_path)
        expect(result).to be_success
        expect(result.data).to eq(%w[Hello World])
      end

      it 'moves files into a folder' do
        paths = ['file1.txt', 'file2.txt', 'file3.txt']
        paths = paths.map { |p| "#{spec_dir}/#{p}" }
        new_dir = "#{spec_dir}/new_dir"

        result = host.mkdir(new_dir)
        expect(result).to be_success

        paths.each do |path|
          file = host.file(path)
          file.touch
          file.append do |f|
            f << 'this is a file'
          end
        end

        result = host.mv(paths, new_dir, target_directory: true)
        expect(result).to be_success
      end

      it 'moves folders' do
        path = "#{spec_dir}/remote-dir-to-move"
        moved_path = "#{spec_dir}/moved-dir"

        result = host.mkdir(path)
        expect(result).to be_success

        result = host.mv(path, moved_path)
        expect(result).to be_success
      end

      it 'removes file' do
        path = "#{spec_dir}/test-rm-file.txt"

        result = host.touch(path)[0]
        expect(host.empty_file?(result.path)).to eq(true)

        result = host.rm(path)
        expect(result.success?).to eq(true)
        expect(host.empty_file?(path)).to eq(false)
      end

      it 'counts a file' do
        result = host.wc('/etc/hosts')

        expect(result.success?).to eq(true)
        expect(result).to respond_to(:lines, :words, :characters)

        lines = result.lines
        result = host.cat('/etc/hosts')

        expect(lines).to eq(result.to_a.length)
      end
    end
  end
end
