require 'serverspec'
include Serverspec::Helper::Exec

describe 'hostsfile_entry - append_existing' do
  it 'creates a new entry if one does not already exist' do
    expect(file('/etc/hosts')).to contain('127.0.0.1.*www.example.com')
  end
end
