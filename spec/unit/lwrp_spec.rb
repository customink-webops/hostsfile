require 'spec_helper'

describe 'hostsfile lwrp' do
  let(:manipulator) { double('manipulator') }

  before do
    Fauxhai.mock(:platform => 'ubuntu', :version => '12.04')

    Manipulator.stub(:new).and_return(manipulator)
    Manipulator.should_receive(:new).with(kind_of(Chef::Node)).and_return(manipulator)
    manipulator.should_receive(:save!).with(no_args())
  end

  let(:chef_run) {
    ChefSpec::ChefRunner.new(:cookbook_path => $cookbook_paths, :step_into => ['hostsfile_entry'])
  }

  context 'actions' do
    describe '(default)' do
      it 'adds the entry' do
        manipulator.should_receive(:add).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => nil, :comment => nil, :priority => nil)
        chef_run.converge('fake::default')
      end
    end

    describe ':create' do
      it 'adds the entry' do
        manipulator.should_receive(:add).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => nil, :comment => nil, :priority => nil)
        chef_run.converge('fake::create')
      end
    end

    describe ':create_if_missing' do
      it 'finds and adds the entry' do
        manipulator.should_receive(:find_entry_by_ip_address).with('2.3.4.5')
        manipulator.should_receive(:add).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => nil, :comment => nil, :priority => nil)
        chef_run.converge('fake::create_if_missing')
      end
    end

    describe ':append' do
      it 'appends the entry' do
        manipulator.should_receive(:append).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => nil, :comment => nil, :priority => nil)
        chef_run.converge('fake::append')
      end
    end

    describe ':update' do
      it 'finds and adds correct entry' do
        manipulator.should_receive(:update).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => nil, :comment => nil, :priority => nil)
        chef_run.converge('fake::update')
      end
    end

    describe ':remove' do
      it 'finds and adds correct entry' do
        manipulator.should_receive(:remove).with('2.3.4.5')
        chef_run.converge('fake::remove')
      end
    end

    context 'options' do
      it 'passes all the options' do
        manipulator.should_receive(:add).with(:ip_address => '2.3.4.5', :hostname => 'www.example.com', :aliases => ['foo', 'bar'], :comment => 'This is a comment!', :priority => 100)
        chef_run.converge('fake::options')
      end
    end
  end
end
