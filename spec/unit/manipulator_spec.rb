require 'spec_helper'

describe Manipulator do
  let(:node) { double('node', :to_hash => {:foo => 'bar'}) }

  let(:lines) do
    [
      "127.0.0.1  localhost",
      "1.2.3.4  example.com",
      "4.5.6.7  foo.example.com"
    ]
  end

  let(:entries) do
    [
      double('entry_1', :ip_address => '127.0.0.1', :hostname => 'localhost', :to_line => '127.0.0.1  localhost'),
      double('entry_2', :ip_address => '1.2.3.4', :hostname => 'example.com', :to_line => '1.2.3.4  example.com'),
      double('entry_3', :ip_address => '4.5.6.7', :hostname => 'foo.example.com', :to_line => '4.5.6.7  foo.example.com')
    ]
  end

  before do
    File.stub(:exists?).and_return(true)
    File.stub(:readlines).and_return(lines)
    manipulator.instance_variable_set(:@entries, entries)
  end

  let(:manipulator) { Manipulator.new(node) }

  describe '.initialize' do
    it 'saves the given node to a hash' do
      node.should_receive(:to_hash).once
      Manipulator.new(node)
    end

    it 'saves the node hash to an instance variable' do
      manipulator = Manipulator.new(node)
      expect(manipulator.node).to eq(node.to_hash)
    end

    it 'raises a fatal error if the hostsfile does not exist' do
      File.stub(:exists?).and_return(false)
      Chef::Application.should_receive(:fatal!).once.and_raise(SystemExit)
      expect {
        Manipulator.new(node)
      }.to raise_error SystemExit
    end

    it 'sends the line to be parsed by the Entry class' do
      lines.each { |l| Entry.should_receive(:parse).with(l) }
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

    let(:options) { { :ip_address => '1.2.3.4', :hostname => 'example.com', :aliases => nil, :comment => 'Some comment', :priority => 5 } }

    before { Entry.stub(:new).and_return(entry) }

    it 'creates a new entry object' do
      Entry.should_receive(:new).with(options)
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
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
      end

      it 'does nothing' do
        manipulator.update(:ip_address => '5.4.3.2', :hostname => 'seth.com')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { double('entry', :hostname= => nil, :aliases= => nil, :comment= => nil, :priority= => nil) }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'updates the hostname' do
        entry.should_receive(:hostname=).with('seth.com')
        manipulator.update(:ip_address => '1.2.3.4', :hostname => 'seth.com')
      end
    end
  end

  describe '#append' do
    let(:options) { { :ip_address => '1.2.3.4', :hostname => 'example.com', :aliases => nil, :comment => 'Some comment', :priority => 5 } }

    context 'when the record exists' do
      let(:entry) { double('entry', options.merge(:aliases= => nil, :comment= => nil)) }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'updates the hostname' do
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options)
      end

      it 'updates the aliases' do
        entry.should_receive(:aliases=).with(['www.example.com'])
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options.merge(:aliases => 'www.example.com'))
      end

      it 'updates the comment' do
        entry.should_receive(:comment=).with('Some comment, This is a new comment!')
        entry.should_receive(:hostname=).with('example.com')
        manipulator.append(options.merge(:comment => 'This is a new comment!'))
      end
    end

    context 'when the record does not exist' do
      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
        manipulator.stub(:add)
      end

      it 'delegates to #add' do
        manipulator.should_receive(:add).with(options).once
        manipulator.append(options)
      end
    end
  end

  describe '#remove' do
    context 'when the entry does not exist' do
      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(nil)
      end

      it 'does nothing' do
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to eq(entries)
      end
    end

    context 'with the entry does exist' do
      let(:entry) { entries[0] }

      before do
        manipulator.stub(:find_entry_by_ip_address).with(any_args()).and_return(entry)
      end

      it 'removes the entry' do
        expect(manipulator.instance_variable_get(:@entries)).to include(entry)
        manipulator.remove('5.4.3.2')
        expect(manipulator.instance_variable_get(:@entries)).to_not include(entry)
      end
    end
  end

  describe '#save' do
    it 'delegates to #save! and returns true' do
      manipulator.stub(:save!)
      manipulator.should_receive(:save!).once
      expect(manipulator.save).to be_true
    end

    it 'returns false if an exception is raised' do
      manipulator.stub(:save!).and_raise(Exception)
      manipulator.should_receive(:save!).once
      expect(manipulator.save).to be_false
    end
  end

  describe '#save!' do
    let(:file) { double('file', :write => true) }

    before do
      File.stub(:open).and_yield(file)
      manipulator.stub(:unique_entries).and_return(entries)
    end

    context 'when the file has not changed' do
      it 'does not write out the file' do
        Digest::SHA512.stub(:hexdigest).and_return('abc123')
        File.should_not_receive(:open)
        manipulator.save!
      end
    end

    context 'when the file has changed' do
      it 'writes out the new file' do
        File.should_receive(:open).with('/etc/hosts', 'w').once
        file.should_receive(:write).once
        manipulator.save!
      end
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

  # Private Methods
  # -------------------------
  describe '#hostsfile_path' do
    before { Manipulator.send(:public, :hostsfile_path) }

    context 'on Windows' do
      let(:node) do
        {
          'platform_family' => 'windows',
          'kernel' => {
            'os_info' => {
              'system_directory' => 'C:\Windows\system32'
            }
          }
        }
      end

      it 'returns the Windows path' do
        expect(manipulator.hostsfile_path).to eq('C:\\Windows\\system32\\drivers\\etc\\hosts')
      end
    end

    context 'everywhere else' do
      it 'returns the Linux path' do
        expect(manipulator.hostsfile_path).to eq('/etc/hosts')
      end
    end
  end

  describe '#current_sha' do
    before do
      Manipulator.send(:public, :current_sha)
      File.stub(:read).with('/etc/hosts').and_return('abc123')
    end

    it 'returns the SHA of the current hostsfile' do
      expect(manipulator.current_sha).to eq('c70b5dd9ebfb6f51d09d4132b7170c9d20750a7852f00680f65658f0310e810056e6763c34c9a00b0e940076f54495c169fc2302cceb312039271c43469507dc')
    end
  end
end
