ruby_block 'insert line to zap' do
  block do
    hosts_file = Chef::Util::FileEdit.new('/etc/hosts')
    hosts_file.insert_line_if_no_match(/^3\.4\.5\.6.*/, '3.4.5.6     zap.example.com')
    hosts_file.write_file
  end
end

hostsfile_entry '2.3.4.6' do
  hostname 'www.example.com'
end

zap_hostsfile_entry '/etc/hosts' do
  filter do |address|
    !%w(127.0.0.1 ::1).include?(address.to_s)
  end
end
