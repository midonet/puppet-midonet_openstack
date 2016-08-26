# == Class: midonet_openstack::params::profile::nova::compute
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
class midonet_openstack::profile::nova::compute {

  include selinux

    $management_network = $::midonet_openstack::params::network_management
    $management_address = ip_for_network($management_network)

    $storage_management_address = $::midonet_openstack::params::storage_address_management
    $controller_management_address = $::midonet_openstack::params::controller_address_management
    $controller_api_address        = $::midonet_openstack::params::controller_address_api

    $user                = $::midonet_openstack::params::mysql_nova_user
    $pass                = $::midonet_openstack::params::mysql_nova_pass
    $api_user            = $::midonet_openstack::params::mysql_nova_api_user
    $api_pass            = $::midonet_openstack::params::mysql_nova_api_pass
    $database_connection = "mysql+pymysql://${user}:${pass}@127.0.0.1/nova"
    $api_database_connection = "mysql+pymysql://${api_user}:${api_pass}@127.0.0.1/nova_api"

    ##midonet_openstack#::resources::firewall { 'Nova Endpoint': port => '8774', }

    unless $::midonet_openstack::params::allinone {
      class { '::nova':
        api_database_connection => $api_database_connection,
        database_connection     => $database_connection,
        rabbit_hosts            => $::midonet_openstack::params::rabbitmq_hosts,
        rabbit_userid           => $::midonet_openstack::params::nova_rabbitmq_user,
        rabbit_password         => $::midonet_openstack::params::nova_rabbitmq_password,
        glance_api_servers      => join($::midonet_openstack::params::glance_api_servers, ','),
        memcached_servers       => ["${::midonet_openstack::params::controller_address_management}:11211"],
        verbose                 => $::midonet_openstack::params::verbose,
        debug                   => $::midonet_openstack::params::debug,
      }


      nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

      class { '::nova::network::neutron':
        neutron_password      => $::midonet_openstack::params::neutron_password,
        neutron_region_name   => $::midonet_openstack::params::region,
        neutron_auth_url      => "http://${controller_management_address}:35357/v3",
        neutron_url           => "http://${controller_management_address}:9696",
        vif_plugging_is_fatal => false,
        vif_plugging_timeout  => '0',
        neutron_project_name  => 'admin',
        neutron_auth_plugin   => 'password'

  }
}


  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $::midonet_openstack::params::controller_address_api,
  }

  if $::osfamily == 'RedHat' {
    package { 'lvm2':
      ensure => latest,
      before => [
        Class['::nova::compute::libvirt', '::nova::compute'],
        Package['device-mapper']
      ]
    }
  }
  class { '::nova::compute::libvirt':
    libvirt_virt_type => $::midonet_openstack::params::nova_libvirt_type,
    vncserver_listen  => '0.0.0.0',
  }

  class { '::nova::migration::libvirt':
  }

  file { '/etc/libvirt/qemu.conf':
  ensure => present,
  source => 'puppet:///modules/midonet_openstack/qemu.conf',
  owner  => 'root',
  group  => 'root',
  mode   => '0644',
  notify => Service['libvirt'],
  }


  selinux::module { 'qemu-kvm':
    ensure      => 'present',
    source      => 'puppet:///modules/midonet_openstack/selinux/qemu-kvm.te',
    syncversion => false,
  }


  if $::osfamily == 'RedHat' {
    package { 'device-mapper':
      ensure => latest
    }
    Package['openstack-nova-network'] -> Package['device-mapper'] ~> Service['libvirtd'] ~> Service['nova-compute']
    package { 'openstack-nova-network':
      ensure => latest,
      notify => Service['nova-compute'],
    } ->
    service { 'openstack-nova-network': enable => false }
  }
  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']

}
