require 'serverspec'
include Serverspec::Helper::Exec

describe 'hostsfile_entry - unique' do
  it 'removes existing hostnames when unique is specified' do
    expect(file('/etc/hosts')).to contain('1.2.3.4[[:space:]]example.com')
    expect(file('/etc/hosts')).to contain('2.3.4.5[[:space:]]www.example.com')

    expect(file('/etc/hosts')).to_not contain('1.2.3.4[[:space:]]example.com[[:space:]]www.example.com')
  end
end
