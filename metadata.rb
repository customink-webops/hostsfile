name             'hostsfile'
maintainer       'Seth Vargo'
maintainer_email 'sethvargo@gmail.com'
license          'Apache-2.0'
description      'Provides an LWRP for managing the /etc/hosts file'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.4.5'
issues_url       'https://github.com/customink-webops/hostsfile/issues' if respond_to?(:issues_url)
source_url       'https://github.com/customink-webops/hostsfile/nrpe' if respond_to?(:source_url)
chef_version     '>= 11.0' if respond_to?(:chef_version)

supports         'redhat'
supports         'ubuntu'

depends          'zap'
