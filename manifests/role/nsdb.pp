#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.
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
# == Class: midonet_openstack::role::nsdb
#
# Sets up a NSDB node with Cassandra & Zookeeper
#
# == Parameters
#
#  [*id*]
#    Id of Zookeeper node
#
#  [*client_ip*]
#    Client ip of zookeeper node
#
#  [*manage_repos*]
#    Whether to install Midonet repositories
#
#  [*manage_java*]
#    Whether to install Java on the target server
#
#  [*zk_servers*]
#    If there are more ZK servers on the cluster, list them here
#
#  [*cassandra_seeds*]
#    If there are more Cassandra servers on the cluster, list them here
#
#  [*cassandra_storage_port*]
#    Storage port for Cassandra
#
#  [*cassandra_ssl_storage_port*]
#    SSL storage port for Cassandra
#
#  [*cassandra_client_port*]
#    Client port for Cassandra
#
#  [*cassandra_client_port_thrift*]
#    Client thrift port for Cassandra
#

class midonet_openstack::role::nsdb (
  $id,
  $client_ip                    = $midonet_openstack::params::nsdb_client_ip,
  $manage_repos                 = $midonet_openstack::params::nsdb_manage_repos,
  $manage_java                  = $midonet_openstack::params::nsdb_manage_java,
  $zk_servers                   = $midonet_openstack::params::zookeeper_servers,
  $cassandra_seeds              = $midonet_openstack::params::cassandra_seeds,
  $cassandra_storage_port       = $midonet_openstack::params::cassandra_storage_port,
  $cassandra_ssl_storage_port   = $midonet_openstack::params::cassandra_ssl_storage_port,
  $cassandra_client_port        = $midonet_openstack::params::cassandra_client_port,
  $cassandra_client_port_thrift = $midonet_openstack::params::cassandra_client_port_thrift,
) inherits ::midonet_openstack::role {

  if $manage_repos and !defined(Class['midonet::repository']) {
    class { '::midonet::repository': }
  }

  if $manage_java and !defined(Class['::midonet_openstack::profile::midojava::midojava']) {
    class { '::midonet_openstack::profile::midojava::midojava': }
    contain midonet_openstack::profile::midojava::midojava
  }

  class { '::midonet_openstack::profile::zookeeper::midozookeeper':
    zk_servers => zookeeper_servers($zk_servers),
    id         => $id,
    client_ip  => $client_ip,
    require    => Class['::midonet_openstack::profile::midojava::midojava']
  }
  contain midonet_openstack::profile::zookeeper::midozookeeper

  class { '::midonet_openstack::profile::cassandra::midocassandra':
    seeds              => $cassandra_seeds,
    seed_address       => $client_ip,
    storage_port       => $cassandra_storage_port,
    ssl_storage_port   => $cassandra_ssl_storage_port,
    client_port        => $cassandra_client_port,
    client_port_thrift => $cassandra_client_port_thrift,
    require            => Class[
      '::midonet_openstack::profile::midojava::midojava',
      '::midonet_openstack::profile::zookeeper::midozookeeper'
    ]
  }
  contain midonet_openstack::profile::cassandra::midocassandra
}
