hostsfile_entry '2.3.4.5' do
  hostname 'www.example.com'
  action   :create_if_missing
end

hostsfile_entry '2.3.4.5' do
  hostname 'domain'
  action   :create_if_missing
end
