require 'spec_helper'

describe Manipulator do
  let(:node) do
    { 'hostsfile' => { 'path' => nil } }
  end

  let(:lines) do
    [
      "127.0.0.1  localhost",
      "1.2.3.4  example.com",
      "4.5.6.7  foo.example.com"
    ]
  end

  let(:entries) do
    [
      Entry.new(ip_address: '127.0.0.1', hostname: 'localhost',       to_line: '127.0.0.1  localhost',     priority: 10),
      Entry.new(ip_address: '1.2.3.4',   hostname: 'example.com',     to_line: '1.2.3.4  example.com',     priority: 20),
      Entry.new(ip_address: '4.5.6.7',   hostname: 'foo.example.com', to_line: '4.5.6.7  foo.example.com', priority: 30)
    ]
  end

  let(:manipulator) { Manipulator.new(node) }
  let(:header) { manipulator.hostsfile_header }

  before do
    allow(File).to receive(:exists?).and_return(true)
    allow(File).to receive(:readlines).and_return(lines)
    manipulator.instance_variable_set(:@entries, entries)
  end

  describe '.initialize' do
    it 'saves the node hash to an instance variable' do
      manipulator = Manipulator.new(node)
      expect(manipulator.node).to be(node)
    end

    it 'raises a fatal error if the hostsfile does not exist' do
      allow(File).to receive(:exists?).and_return(false)
      expect { Manipulator.new(node) }.to raise_error(RuntimeError)
    end

    it 'sends the line to be parsed by the Entry class' do
      lines.each { |l| allow(Entry).to receive(:parse).with(l) }
      Manipulator.new(node)
    end
  end

  describe '#ip_addresses' do
    it 'returns a list of all the IP Addresses' do
      expect(manipulator.ip_addresses).to eq(entries.map(&:ip_address))
    end
  end

  describe '#add' do
    let(:entry) { double('entry') }

    let(:options) { { ip_address: '1.2.3.4', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }

    before { allow(Entry).to receive(:new).and_return(entry) }

    it 'creates a new entry object' do
      allow(Entry).to receive(:new).with(options)
      manipulator.add(options)
    end

    it 'pushes the new entry onto the collection' do
      manipulator.add(options)
      expect(manipulator.instance_variable_get(:@entries)).to include(entry)
    end
  end

  describe '#update' do
    context 'when the entry does not exist' do
      before do
        allow(manipulator).to receive(:find_entry_by_ip_address)
          .with(any_args())
          .and_return(nil)
      end

      it 'does nothing' do
        manipulator.update(ip_address: '5.4.3.2', hostname: 'seth.com')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { double('entry', :hostname= => nil, :aliases= => nil, :comment= => nil, :priority= => nil) }

      before do
        allow(manipulator).to receive(:find_entry_by_ip_address)
          .with(any_args())
          .and_return(entry)
      end

      it 'updates the hostname' do
        allow(entry).to receive(:hostname=).with('seth.com')
        manipulator.update(ip_address: '1.2.3.4', hostname: 'seth.com')
      end
    end
  end

  describe '#append' do
    let(:options) { { ip_address: '1.2.3.4', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }

    context 'when the record exists' do
      let(:entry) { double('entry', options.merge(:aliases= => nil, :comment= => nil)) }

      before do
        allow(manipulator).to receive(:find_entry_by_ip_address)
          .with(any_args())
          .and_return(entry)
      end

      it 'updates the hostname' do
        allow(entry).to receive(:hostname=).with('example.com')
        manipulator.append(options)
      end

      it 'updates the aliases' do
        allow(entry).to receive(:aliases=).with(['www.example.com'])
        allow(entry).to receive(:hostname=).with('example.com')
        manipulator.append(options.merge(aliases: 'www.example.com'))
      end

      it 'updates the comment' do
        allow(entry).to receive(:comment=).with('Some comment, This is a new comment!')
        allow(entry).to receive(:hostname=).with('example.com')
        manipulator.append(options.merge(comment: 'This is a new comment!'))
      end
    end

    context 'when the record does not exist' do
      before do
        allow(manipulator).to receive(:find_entry_by_ip_address)
          .with(any_args())
          .and_return(nil)
        allow(manipulator).to receive(:add)
      end

      it 'delegates to #add' do
        allow(manipulator).to receive(:add).with(options).once
        manipulator.append(options)
      end
    end
  end

  describe '#remove' do
    context 'when the entry does not exist' do
      before do
        allow(manipulator).to receive(:find_entry_by_ip_address).with(any_args()).and_return(nil)
      end

      it 'does nothing' do
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { entries[0] }

      before do
        allow(manipulator).to receive(:find_entry_by_ip_address)
          .with(any_args())
          .and_return(entry)
      end

      it 'removes the entry' do
        expect(manipulator.instance_variable_get(:@entries)).to include(entry)
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to_not include(entry)
      end
    end
  end

  describe '#new_content' do
    let(:entries_string) { entries.map(&:to_line).join("\n").concat("\n") }

    before do
      manipulator.class.send(:public, :new_content)
      manipulator.class.send(:public, :hostsfile_header)
      allow(manipulator).to receive(:unique_entries).and_return(entries)
    end

    it 'starts with comment header' do
      expect(manipulator.new_content).to start_with(header.join("\n").concat("\n"))
    end

    it 'ends with all unique entry lines' do
      expect(manipulator.new_content).to end_with(entries_string)
    end
  end

  describe '#content_changed?' do
    let(:current_content) do
      (header << entries.map(&:to_line) << '').flatten.join("\n")
    end

    before do
      allow(File).to receive(:read).and_return(current_content)
      allow(manipulator).to receive(:unique_entries).and_return(entries)
    end

    context 'when content has not changed' do
      it 'returns false' do
        expect(manipulator.content_changed?).to be_falsey
      end
    end

    context 'when content has changed' do
      it 'returns true' do
        manipulator.remove('4.5.6.7')
        expect(manipulator.content_changed?).to be_truthy
      end
    end
  end

  describe '#hostsfile_header' do
    it 'is an array' do
      expect(manipulator.hostsfile_header).to be_an(Array)
    end

    it 'each line is blank or starts with comment' do
      manipulator.hostsfile_header.each do |item|
        expect(item).to match(/^(\s*|#.*)/)
      end
    end
  end

  describe '#save' do
    let(:file) { double('file', content: nil, run_action: nil) }

    before do
      allow(Chef::Resource::File).to receive(:new).and_return(file)
      allow(manipulator).to receive(:unique_entries).and_return(entries)
      allow(node).to receive(:run_context)
    end

    it 'writes out the new file' do
      expect(Chef::Resource::File).to receive(:new).with('/etc/hosts', nil)
      expect(file).to receive(:content).once
      expect(file).to receive(:run_action).with(:create).once
      manipulator.save
    end
  end

  describe '#find_entry_by_ip_address' do
    it 'finds the associated entry' do
      expect(manipulator.find_entry_by_ip_address('127.0.0.1')).to eq(entries[0])
      expect(manipulator.find_entry_by_ip_address('1.2.3.4')).to eq(entries[1])
      expect(manipulator.find_entry_by_ip_address('4.5.6.7')).to eq(entries[2])
    end

    it 'returns nil if the entry does not exist' do
      expect(manipulator.find_entry_by_ip_address('77.77.77.77')).to be_nil
    end
  end

  describe '#hostsfile_path' do
    before do
      manipulator.class.send(:public, :hostsfile_path)
      allow(File).to receive(:exists?).and_return(true)
    end

    context 'with no node attribute specified' do
      it 'returns /etc/hosts on a *nix machine' do
        expect(manipulator.hostsfile_path).to eq('/etc/hosts')
      end
      it 'returns C:\Windows\system32\drivers\etc\hosts on a Windows machine' do
        windows_attributes = node.merge({ 'platform_family' => 'windows', 'kernel' => { 'os_info' => { 'system_directory' => 'C:\Windows\system32' } } })
        expect(Manipulator.new(windows_attributes).hostsfile_path).to eq('C:\Windows\system32\drivers\etc\hosts')
      end
    end

    context 'with a custom hostsfile node attribute' do
      it 'returns the custom path' do
        custom_path = '/custom/path'
        expect(Manipulator.new(node.merge({'hostsfile' => { 'path' => custom_path } })).hostsfile_path).to eq(custom_path)
      end
    end
  end

  describe '#remove_existing_hostnames' do
    before { manipulator.class.send(:public, :remove_existing_hostnames) }

    context 'with no duplicates' do
      it 'does not change anything' do
        entry = Entry.new(ip_address: '7.8.9.10', hostname: 'new.example.com')
        entries << entry

        expect {
          manipulator.remove_existing_hostnames(entry)
        }.to_not change(manipulator, :entries)
      end
    end

    context 'with duplicate hostnames' do
      it 'removes the duplicate hostnames' do
        entry = Entry.new(ip_address: '7.8.9.10', hostname: 'example.com')
        entries << entry

        manipulator.remove_existing_hostnames(entry)
        expect(manipulator.entries).to_not include(entries[1])
      end
    end

    context 'with duplicate aliases' do
      it 'removes the duplicate aliases' do
        entry = Entry.new(ip_address: '7.8.9.10', hostname: 'bar.example.com')
        entries << entry
        entries[1].aliases = ['bar.example.com']

        manipulator.remove_existing_hostnames(entry)
        expect(manipulator.entries).to include(entries[1])
        expect(manipulator.entries[1].aliases).to be_empty
      end
    end
  end
end
