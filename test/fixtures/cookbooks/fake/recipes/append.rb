hostsfile_entry '2.3.4.5' do
  hostname    'www.example.com'
  action      :append
end

hostsfile_entry '6.7.8.9' do
  hostname    'www.example1.com'
  aliases     ['www.example2.com',
               'www.example3.com',
               'www.example4.com',
               'www.example5.com',
               'www.example6.com',
               'www.example7.com',
               'www.example8.com',
               'www.example9.com',
               'www.example10.com',
               'www.example11.com',
               'www.example12.com']
  action      :append
end
