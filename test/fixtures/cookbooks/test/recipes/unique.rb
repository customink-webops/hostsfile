hostsfile_entry '1.2.3.4' do
  hostname 'example.com'
  aliases  ['www.example.com']
end

hostsfile_entry '2.3.4.5' do
  hostname 'www.example.com'
  unique   true
end
