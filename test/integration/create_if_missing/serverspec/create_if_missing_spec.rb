require 'serverspec'
include Serverspec::Helper::Exec

describe 'hostsfile_entry - create_if_missing' do
  it 'creates a new entry if one is missing' do
    expect(file('/etc/hosts')).to contain('2.3.4.5[[:space:]]www.example.com')
  end

  it 'does not create an entry if one exists' do
    expect(file('/etc/hosts')).to_not contain('domain')
  end
end
