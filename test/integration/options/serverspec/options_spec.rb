require 'serverspec'
include Serverspec::Helper::Exec

describe 'hostsfile_entry - options' do
  it 'appends all options to the entry' do
    expect(file('/etc/hosts')).to contain('2.3.4.5')
    expect(file('/etc/hosts')).to contain('www.example.com')
    expect(file('/etc/hosts')).to contain('foo')
    expect(file('/etc/hosts')).to contain('bar')
    expect(file('/etc/hosts')).to contain('comment')
    expect(file('/etc/hosts')).to contain('@100')
  end
end
