name             'hostsfile'
maintainer       'Seth Vargo'
maintainer_email 'sethvargo@gmail.com'
license          'Apache-2.0'
description      'Provides an resource for managing the /etc/hosts file'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.1'
issues_url       'https://github.com/customink-webops/hostsfile/issues'
source_url       'https://github.com/customink-webops/hostsfile'
chef_version     '>= 12.7' if respond_to?(:chef_version)
supports         'all'
