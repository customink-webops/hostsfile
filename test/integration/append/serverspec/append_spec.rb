require 'serverspec'
set :backend, :exec

describe 'hostsfile_entry - append' do
  it 'creates a new entry if one does not already exist' do
    expect(file('/etc/hosts')).to contain('2.3.4.5[[:space:]]www.example.com')
  end

  if os[:family] == 'windows'
    it 'expects 1th entry to be normal in windows' do
      expect(file('/etc/hosts')).to contain('6.7.8.9[[:space:]]www.example1.com')
    end

    it 'expects 10th entry to be wrapped in windows' do
      expect(file('/etc/hosts')).to contain('6.7.8.9[[:space:]]www.example10.com')
    end
  end
end
