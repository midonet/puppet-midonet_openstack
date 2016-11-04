# Starts up standard firewall rules. Pre-runs
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class midonet_openstack::profile::firewall::pre {

  # Set up the initial firewall rules for all nodes
  firewallchain { 'INPUT:filter:IPv4':
    purge  => true,
    ignore => ['neutron','virbr0'],
    before => Firewall['0001 - related established'],
  }

  include ::firewall

  # Default firewall rules, based on the RHEL defaults
  firewall { '0001 - related established':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
    before => [ Class['::firewall'] ],
  } ->
  firewall { '0002 - localhost':
    proto  => 'icmp',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0003 - localhost':
    proto  => 'all',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0022 - ssh':
    proto  => 'tcp',
    state  => ['NEW', 'ESTABLISHED', 'RELATED'],
    action => 'accept',
    dport  => 22,
    before => [ Firewall['8999 - Accept all management network traffic'] ],
  }
}
