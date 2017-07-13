#
# rubocop:disable AsciiComments
#
# Author:: Bogdan Katyński <bogdan.katynski@gmail.com>
# Cookbook Name:: hostsfile
# Spec:: default
#
# Copyright:: 2017, Bogdan Katyński
# Copyright:: 2017, Workday, Inc.
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
#

require 'spec_helper'

describe 'hostsfile::default' do
  let(:runner) { ChefSpec::SoloRunner.new }
  let(:node) { chef_run.node }
  let(:chef_run) { runner.converge(described_recipe) }

  context 'When all attributes are default' do
    it 'does not update /etc/hosts' do
      expect(chef_run).not_to create_hostsfile_entry(node['ipaddress'])
    end
  end

  context 'When add_fqdn attr is true' do
    let(:runner) do
      ChefSpec::SoloRunner.new do |node|
        node.override['hostsfile']['add_fqdn'] = true
      end
    end
    it 'creates a mapping for the fqdn in /etc/hosts' do
      expect(chef_run).to create_hostsfile_entry(node['ipaddress'])
        .with(unique: true, hostname: node['fqdn'])
    end
  end

  context 'when there are hostsfile entries in the node attribute' do
    let(:entries) do
      {
        '1.2.3.4' => {
          hostname: 'host1.some.test.domain',
          unique: false
        },
        '2.3.4.5' => {
          hostname: 'host2.some.test.domain',
          unique: true,
          aliases: %w(alias1.some.test.domain alias2.some.test.domain)
        }
      }
    end
    let(:runner) do
      ChefSpec::SoloRunner.new do |node|
        node.override['hostsfile']['entries'] = entries
      end
    end

    it 'creates mappings for all entries in /etc/hosts' do
      entries.each do |ip, attrs|
        expect(chef_run).to create_hostsfile_entry(ip).with(attrs)
      end
    end

    context 'when there is a hostfile entry with an unsupported attribute' do
      let(:entries) do
        {
          '1.2.3.4' => {
            hostname: 'host1.some.test.domain',
            action: :unsupported_action
          }
        }
      end

      it 'raises an error' do
        expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
