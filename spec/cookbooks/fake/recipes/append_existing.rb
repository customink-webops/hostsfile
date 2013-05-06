# We can guarantee that 127.0.0.1 exists on every system...
hostsfile_entry '127.0.0.1' do
  hostname    'www.example.com'
  action      :append
end
