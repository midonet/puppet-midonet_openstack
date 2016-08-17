# == Class: ::midonet_openstack::profile::cassandra::midocassandra
#
# Install and run the cassandra component
#
# === Parameters
#
#  [*seeds*]
#    Full list of cassandra seeds that belong to a cluster.
#  [*seed_address*]
#    IP address to bind for this instance. (Must belong to the
#    seeders list.
#  [*storage_port*]
#    Inter-node cluster communication port (defaulted to 7000).
#  [*ssl_storage_port*]
#    SSL Inter-node cluster communication port (defaulted to 7001).
#  [*client_port*]
#    Cassandra client port (defaulted to 9042).
#  [*client_port_thrift*]
#    Cassandra client port thrift (defaulted to 9160).
#
#
# === Examples
#
# * The easiest way to run the class is:
#
#       include ::cassandra
#
#   And a cassandra single-machine cluster will be installed, binding the
#   'localhost' address.
#
# * Run a single-machine cluster but binding a hostname or another address
#   would be:
#
#        class {'::midonet::cassandra':
#            seeds              => ['192.168.2.2'],
#            seed_address       => '192.168.2.2',
#            storage_port       => 7000,
#            ssl_storage_port   => 7001,
#            client_port        => 9042,
#            client_port_thrift => 9042,
#        }
#
# *  All the ports must be configured the same in all the nodes in the cluster.
#
# * For cluster of nodes, use the same 'seeds' value, but change the
#   seed_address of each node:
#
# - On node1
#        class {'::midonet::cassandra':
#            seeds              => ['node_1', 'node_2', 'node_3'],
#            seed_address       => 'node_1'
#            storage_port       => 7000,
#            ssl_storage_port   => 7001,
#            client_port        => 9042,
#            client_port_thrift => 9042,
#        }
# - On node2
#        class {'::midonet::cassandra':
#            seeds              => ['node_1', 'node_2', 'node_3'],
#            seed_address       => 'node_2'
#            storage_port       => 7000,
#            ssl_storage_port   => 7001,
#            client_port        => 9042,
#            client_port_thrift => 9042,
#        }
# - On node3
#        class {'::midonet::cassandra':
#            seeds              => ['node_1', 'node_2', 'node_3'],
#            seed_address       => 'node_3'
#            storage_port       => 7000,
#            ssl_storage_port   => 7001,
#            client_port        => 9042,
#            client_port_thrift => 9042,
#        }
#
# NOTE: node_X can be either hostnames or ip addresses
# You can alternatively use the Hiera.yaml style:
#
#     ::midonet::cassandra::seeds:
#         - node_1
#         - node_2
#         - node_3
#     ::midonet::cassandra::seed_address: 'node_1'
#
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
#
# == Parameters
#
#  [*seeds*]
#    List of cassandra seeds in '<seed1>,<seed2>' format
#  [*seed_address*]
#    Node address for the seed
#  [*storage_port*]
#    Storage Port
#  [*ssl_storage_port*]
#    SSL Storage Port
#  [*client_port*]
#    Client Port. Default 9042
#  [*client_port_thrift*]
#    Client Port for Thrift.


class midonet_openstack::profile::cassandra::midocassandra (
  $seeds,
  $seed_address,
  $storage_port = '7000',
  $ssl_storage_port = '7001',
  $client_port = '9042',
  $client_port_thrift = '9160',
  )
{
  # Cassandra pre-requisites.  You may want to install your own Java
  # environment.
  include cassandra::datastax_repo
  midonet_openstack::resources::firewall { 'Cassandra Client Port': port => $client_port, }
  midonet_openstack::resources::firewall { 'Cassandra Port Thrift': port => $client_port_thrift, }


  if $::osfamily == 'RedHat' or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '14.10') > 0) {
    #Cassandra systemd for newer versions
    $is_systemd = true
  }
  else {
    $is_systemd = false
  }
  ## Hard-pin the version here since midonet requires 2.2
  if $::osfamily == 'RedHat' {
    $version = '2.2.4-1'
  } else {
    $version = '2.2.4'
  }

  class {'::cassandra':
    seeds                 => $seeds,
    listen_address        => $seed_address,
    storage_port          => $storage_port,
    ssl_storage_port      => $ssl_storage_port,
    native_transport_port => $client_port,
    rpc_port              => $client_port_thrift,
    package_ensure        => $version,
    service_systemd       => $is_systemd,
    require               => Class['cassandra::datastax_repo'],
    before                => Class['cassandra::firewall_ports']
  }
  contain '::cassandra'

  class {'::cassandra::firewall_ports':
    client_ports      => [$client_port,$client_port_thrift],
  }

}
