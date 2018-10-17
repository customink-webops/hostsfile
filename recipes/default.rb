#
# rubocop:disable AsciiComments
#
# Author:: Bogdan Katyński <bogdan.katynski@workday.com>
# Cookbook Name:: hostsfile
# Recipe:: default
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# rubocop:enable AsciiComments

# Create a mapping for the FQDN
hostsfile_entry node['ipaddress'] do
  hostname  node['fqdn']
  action    :create
  unique    true
  only_if   { node['hostsfile']['add_fqdn'] }
end

node['hostsfile']['entries'].each do |ip, attrs|
  hostsfile_entry ip do
    attrs.each { |a, v| send(a, v) }
  end
end