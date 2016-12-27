# == Class: midonet_openstack::params::profile::nova::compute
#
# Configures nova on a compute node
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
#  [*rabbitmq_hosts*]
#    Rabbitmq hosts as a list
#
#  [*rabbitmq_user*]
#    Rabbitmq Username
#
#  [*rabbitmq_password*]
#    Rabbitmq password
#
#  [*glance_api_servers*]
#    List of glance api servers
#
#  [*memcached_servers*]
#    List of memcached servers
#
#  [*compute_mgmnt_address*]
#    Self binding address
#
#  [*management_network*]
#    CIDR of management network
#
#  [*management_address*]
#    Self address on management network
#
#  [*controller_management_address*]
#    Controller management address
#
#  [*controller_api_address*]
#    Controller api address
#
#  [*user*]
#    Nova mysql username
#
#  [*pass*]
#    Nova Mysql password
#
#  [*verbose*]
#    Activate verbose output for nova logs
#
#  [*debug*]
#    Activate debug output for nova logs
#
#  [*neutron_password*]
#    Neutron password
#
#  [*region_name*]
#    Openstack region_name
#
#  [*nova_libvirt_type*]
#    Nova libvirt type
#
class midonet_openstack::profile::nova::compute(
  $rabbitmq_hosts                = $::midonet_openstack::params::rabbitmq_hosts,
  $rabbitmq_user                 = $::midonet_openstack::params::nova_rabbitmq_user,
  $rabbitmq_password             = $::midonet_openstack::params::nova_rabbitmq_password,

  $glance_api_servers            = $::midonet_openstack::params::glance_api_servers,
  $memcached_servers             = ["${::midonet_openstack::params::controller_address_management}:11211"],

  $compute_mgmnt_address         = $::ipaddress,
  $management_network            = $::midonet_openstack::params::network_management,
  $management_address            = ip_for_network($management_network),
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_api_address        = $::midonet_openstack::params::controller_address_api,

  $user                          = $::midonet_openstack::params::mysql_nova_user,
  $pass                          = $::midonet_openstack::params::mysql_nova_pass,
  $api_user                      = $::midonet_openstack::params::mysql_nova_api_user,
  $api_pass                      = $::midonet_openstack::params::mysql_nova_api_pass,

  $verbose                       = $::midonet_openstack::params::verbose,
  $debug                         = $::midonet_openstack::params::debug,

  $neutron_password              = $::midonet_openstack::params::neutron_password,
  $region_name                   = $::midonet_openstack::params::region,

  $nova_libvirt_type             = $::midonet_openstack::params::nova_libvirt_type

  ) {

    include stdlib



    $database_connection = "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova"
    $api_database_connection = "mysql+pymysql://${api_user}:${api_pass}@${controller_management_address}/nova_api"

    ##midonet_openstack#::resources::firewall { 'Nova Endpoint': port => '8774', }

    unless $::midonet_openstack::params::allinone {

      class { '::nova':
        api_database_connection => $api_database_connection,
        database_connection     => $database_connection,
        rabbit_hosts            => $rabbitmq_hosts,
        rabbit_userid           => $rabbitmq_user,
        rabbit_password         => $rabbitmq_password,
        glance_api_servers      => join($glance_api_servers, ','),
        memcached_servers       => $memcached_servers,
        verbose                 => $verbose,
        debug                   => $debug,
      }


      nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

      class { '::nova::network::neutron':
        neutron_password      => $neutron_password,
        neutron_region_name   => $region_name,
        neutron_auth_url      => "http://${controller_management_address}:35357/v3",
        neutron_url           => "http://${controller_management_address}:9696",
        vif_plugging_is_fatal => false,
        vif_plugging_timeout  => '0',
        neutron_project_name  => 'services',
        neutron_auth_plugin   => 'password'

  }
}


  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $controller_api_address,
  }

  if $::osfamily == 'RedHat' {
    package { 'lvm2':
      ensure => latest,
      before => [
        Package['device-mapper']
      ]
    }

    exec { 'install-libvirt-python':
      command => '/bin/rpm -Uvh ftp://195.220.108.108/linux/centos/7.2.1511/os/x86_64/Packages/libvirt-python-1.2.17-2.el7.x86_64.rpm',
    }

    Package['libvirt'] -> Exec['install-libvirt-python']

    # TODO: Add CentOS 7.2 vault repo in puppet
    Package<| title == "libvirt" |> { ensure => '1.2.17' }
    Package<| title == "libvirt-nwfilter" |> { ensure => '1.2.17' }
  }
  class { '::nova::compute::libvirt':
    libvirt_virt_type => $nova_libvirt_type,
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


  if $::osfamily == 'RedHat' {
    include selinux
    selinux::module { 'qemu-kvm':
      ensure      => 'present',
      source      => 'puppet:///modules/midonet_openstack/selinux/qemu-kvm.te',
      syncversion => false,
    }
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
