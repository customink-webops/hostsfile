entries = node['hostsfile']['entries']

entries.each do |entry|
  hostsfile_entry entry['ip_address'] do
    hostname  entry['hostname']
    aliases   entry['aliases']
    action    :create
  end
end
