# == Class: midonet_openstack::role::nsdb
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

#  [*id*]
#    Id of zookeeper node
#  [*client_ip*]
#    client ip of zookeeper node
#  [*manage_repos*]
#    Should install midonet repos?
#  [*manage_java*]
#    Should install java?
#  [*zk_servers*]
#    List of zookeeper servers
class midonet_openstack::role::nsdb (
    $id                   = 1,
    $client_ip            = $::ipaddress,
    $manage_repos         = true,
    $manage_java          = true,
    $zk_servers           = $midonet_openstack::params::zookeeper_servers
  ) inherits ::midonet_openstack::role {

    if $manage_repos and !defined(Class['midonet::repository']){
      class { '::midonet::repository': }
    }

    if $manage_java and !defined(Class['::midonet_openstack::profile::midojava::midojava']) {
      class { '::midonet_openstack::profile::midojava::midojava':}
      contain '::midonet_openstack::profile::midojava::midojava'
    }

    class {'::midonet_openstack::profile::zookeeper::midozookeeper':
      zk_servers => zookeeper_servers($zk_servers),
      id         => $id,
      client_ip  => $client_ip,
      require    => Class['::midonet_openstack::profile::midojava::midojava']
    }
    contain '::midonet_openstack::profile::zookeeper::midozookeeper'

    class {'::midonet_openstack::profile::cassandra::midocassandra':
      seeds              => $::midonet_openstack::params::cassandra_seeds,
      seed_address       => $client_ip,
      storage_port       => '7000',
      ssl_storage_port   => '7001',
      client_port        => '9042',
      client_port_thrift => '9160',
      require            => Class['::midonet_openstack::profile::midojava::midojava',
                                  '::midonet_openstack::profile::zookeeper::midozookeeper']
    }
    contain '::midonet_openstack::profile::cassandra::midocassandra'
    if $::osfamily == 'RedHat' {
      Package<| title = 'zookeeper' |> { ensure => '3.4.5-1'}
    }
}
