# == Class: midonet_openstack::profile::zookeeper::midozookeeper
#
#  Configure Zookeeper
# == Parameters
#
#  [*id*]
#    Zookeeper Host Id
#
#  [*client_ip*]
#    Zookeeper client ip
#
#  [*zk_servers*]
#    List of zookeeper servers
#
#  [*cfg_dir*]
#    Zookeeper config directory
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

class midonet_openstack::profile::zookeeper::midozookeeper(
  $zk_servers,
  $id                   = 1,
  $client_ip            = $::ipaddress_eth0,
  $cfg_dir              = '/etc/zookeeper/conf',
  ){

    ##midonet_openstack#::resources::firewall { 'Zookeeper': port => '2181'}
    if $::osfamily == 'RedHat'
    {
      $zk_packages = ['zookeeper']

      class { '::zookeeper':
        servers             => $zk_servers,
        id                  => $id,
        cfg_dir             => $cfg_dir,
        client_ip           => $client_ip,
        packages            => $zk_packages,
        service_name        => 'zookeeper',
        manage_service      => false,
        manage_service_file => false,
      }
      contain zookeeper

      service { 'zookeeper-service':
        ensure  => 'running',
        name    => 'zookeeper',
        enable  => true,
        require => [
          File["${cfg_dir}/zoo.cfg"],
        ],
      }

      Class['zookeeper::os::redhat'] ->
      Class['zookeeper::config'] ->
      #File['zookeeper-old-initscript'] ->
      Service['zookeeper-service']

    }
    elsif $::osfamily == 'Debian'
    {
      $zk_packages = ['zookeeper','zookeeperd']

      class { '::zookeeper':
        servers      => $zk_servers,
        id           => $id,
        cfg_dir      => $cfg_dir,
        client_ip    => $client_ip,
        packages     => $zk_packages,
        service_name => 'zookeeper',
        require      => [ File['/usr/java/default'] ],
      }
      contain zookeeper
    }
    else {
      fail("Unsupported Operating System Family ${::osfamily}")
    }
  }
