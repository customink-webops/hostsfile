describe 'hostsfile_entry - default' do
  it 'creates a new entry' do
    expect(file('/etc/hosts')).to contain('2.3.4.5[[:space:]]www.example.com')
  end
end
