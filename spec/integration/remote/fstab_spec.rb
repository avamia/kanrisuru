# frozen_string_literal: true

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Remote::Fstab do
    context "with #{os_name}" do
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

      it 'outputs string version of fstab' do
        host.su('root')

        result = host.cat('/etc/fstab')
        expect(result).to be_success
        raw_file_lines = []
        result.each do |line|
          next if line.match(/^#/) || line == ''

          raw_file_lines << line.split.join(' ')
        end

        raw_file_output = raw_file_lines.join("\n")
        expect(raw_file_output).to eq(host.fstab.to_s)
      end

      it 'parses fstab' do
        host.su('root')
        fstab = host.fstab

        entry =
          case os_name
          when 'opensuse'
            fstab['/dev/vda3']
          when 'sles'
            fstab['/dev/xvda1']
          else
            fstab['/dev/vda1']
          end

        expect(fstab.get_entry(entry.uuid)).to eq(entry)
        expect(fstab.get_entry(entry.label)).to eq(entry)

        fstab << Kanrisuru::Remote::Fstab::Entry.new(
          device: '/dev/vda14',
          mount_point: '/mnt/test',
          type: 'ext4',
          opts: { defaults: true },
          freq: '0',
          passno: '0'
        )

        entry = fstab['/dev/vda14']
        expect(entry.to_s).to eq('/dev/vda14 /mnt/test ext4 defaults 0 0')
        expect(entry.device).to eq('/dev/vda14')
        expect(entry.mount_point).to eq('/mnt/test')
        expect(entry.type).to eq('ext4')
        expect(entry.opts.to_s).to eq('defaults')
        expect(entry.freq).to eq('0')
        expect(entry.passno).to eq('0')

        entry.opts['defaults'] = false
        entry.opts['user'] = true
        entry.opts['exec'] = true
        entry.opts['rw'] = true
        entry.opts['auto'] = true
        entry.opts['relatime'] = true
        entry.opts['async'] = true
        entry.opts[:nodev] = true
        entry.opts[:nosuid] = true
        entry.opts[:owner] = true
        entry.opts[:group] = true

        entry.mount_point = '/mnt/test3'

        expect(fstab['/dev/vda14'].to_s).to eq '/dev/vda14 /mnt/test3 ext4 ' \
                                               'user,exec,rw,auto,relatime,async,nodev,nosuid,owner,group 0 0'

        fstab << '/dev/vda16 /mnt/test2 fat defaults,user,uid=1000,gid=1000 0 0'
        expect(fstab['/dev/vda16'].to_s).to eq('/dev/vda16 /mnt/test2 fat defaults,user,uid=1000,gid=1000 0 0')
      end
    end
  end
end
