# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Stream do
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

  it 'prepares head command' do
    result = host.head('/var/log/syslog')
    expect_command(result, 'head /var/log/syslog')

    result = host.head('/var/log/syslog', bytes: 1024)
    expect_command(result, 'head -c 1024 /var/log/syslog')

    result = host.head('/var/log/syslog', lines: 50)
    expect_command(result, 'head -n 50 /var/log/syslog')
  end

  it 'prepares tail command' do
    result = host.tail('/var/log/syslog')
    expect_command(result, 'tail /var/log/syslog')

    result = host.tail('/var/log/syslog', bytes: 1024)
    expect_command(result, 'tail -c 1024 /var/log/syslog')

    result = host.tail('/var/log/syslog', lines: 50)
    expect_command(result, 'tail -n 50 /var/log/syslog')
  end

  it 'prepares read_file_chunk command' do
    result = host.read_file_chunk('/var/log/apache2/access.log', 10, 20)
    expect_command(result, 'tail -n +10 /var/log/apache2/access.log | head -n 11')

    result = host.read_file_chunk('/var/log/apache2/access.log', 0, 0)
    expect_command(result, 'tail -n +0 /var/log/apache2/access.log | head -n 1')

    expect do
      host.read_file_chunk('file.log', 10, '20')
    end.to raise_error(ArgumentError)

    expect do
      host.read_file_chunk('file.log', '10', 20)
    end.to raise_error(ArgumentError)

    expect do
      host.read_file_chunk('file.log', 10, 9)
    end.to raise_error(ArgumentError)

    expect do
      host.read_file_chunk('file.log', -1, 1)
    end.to raise_error(ArgumentError)

    expect do
      host.read_file_chunk('file.log', 10, -2)
    end.to raise_error(ArgumentError)
  end

  it 'prepares sed command' do
    result = host.sed('~/file.txt', 'Cat', 'Dog')
    expect_command(result, "sed 's/Cat/Dog/g' '~/file.txt'")

    result = host.sed('~/file.txt', 'Cat', 'Doggz', in_place: true, new_file: '~/file2.txt', mode: 'write')
    expect_command(result, "sed -i 's/Cat/Doggz/g' '~/file.txt' > ~/file2.txt")

    result = host.sed('~/file.txt', 'Cat', 'Dogo', regexp_extended: true, new_file: '~/file2.txt', mode: 'append')
    expect_command(result, "sed -r 's/Cat/Dogo/g' '~/file.txt' >> ~/file2.txt")
  end

  it 'prepares echo command' do
    expect_command(host.echo('Hello world'), "echo 'Hello world'")
    expect_command(host.echo('Hello\\n world', backslash: true), "echo -e 'Hello\\n world'")

    expect_command(host.echo('Hello world', new_file: '~/file1.txt', mode: 'write'),
                   "echo 'Hello world' > ~/file1.txt")

    expect_command(host.echo('Goodbye', new_file: '~/file1.txt', mode: 'append'),
                   "echo 'Goodbye' >> ~/file1.txt")
  end

  it 'prepares cat command' do
    expect_command(host.cat('/etc/group'), 'cat /etc/group')
    expect_command(host.cat('/etc/group', show_all: true), 'cat -A /etc/group')
    expect_command(host.cat('/etc/group',
                            show_tabs: true,
                            number: true,
                            squeeze_blank: true,
                            show_nonprinting: true,
                            show_ends: true,
                            number_nonblank: true), 'cat -T -n -s -v -E -b /etc/group')

    expect_command(host.cat(['~/file1.txt', '~/file2.txt', '~/file3.txt']),
                   'cat ~/file1.txt ~/file2.txt ~/file3.txt')

    expect_command(host.cat(['~/file1.txt', '~/file2.txt', '~/file3.txt'], mode: 'write', new_file: 'combined.txt'),
                   'cat ~/file1.txt ~/file2.txt ~/file3.txt > combined.txt')

    expect_command(host.cat(['~/file1.txt', '~/file2.txt', '~/file3.txt'], mode: 'append', new_file: 'combined.txt'),
                   'cat ~/file1.txt ~/file2.txt ~/file3.txt >> combined.txt')
  end
end
