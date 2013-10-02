require 'serverspec'
include Serverspec::Helper::Exec

describe 'hostsfile_entry - append' do
  it 'creates a new entry if one does not already exist' do
    expect(file('/etc/hosts')).to contain('2.3.4.5[[:space:]]www.example.com')
  end
end
