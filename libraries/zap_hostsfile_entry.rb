#
# Cookbook Name:: hostsfile
# HWRP:: zap_hostsfile_entry
#
# Author:: Dmitry Shestoperov <dmitry@shestoperov.info>
#
# Copyright:: 2017, Dmitry Shestoperov.
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

class Chef
  # resource
  class Resource::ZapHostsfileEntry < Resource::Zap
    def initialize(name, run_context = nil)
      super

      # Set the resource name and provider and default action
      @action = :remove
      @resource_name = :zap_hostsfile_entry
      @supports << :filter
      @provider = Provider::ZapHostsfileEntry
      @klass = [Chef::Resource.resource_for_node(:hostsfile_entry, node)]
    end
  end

  # provider
  class Provider::ZapHostsfileEntry < Provider::Zap
    def collect
      all = (hostsfile.ip_addresses.select { |ip_address| @filter.call(ip_address) }).map(&:to_s)
      all
    end

    def select(r)
      r.ip_address if @klass.map { |k| class_for_node(k) }.flatten.include?(r.class)
    end

    def hostsfile
      @hostsfile ||= Manipulator.new(node)
    end
  end
end
