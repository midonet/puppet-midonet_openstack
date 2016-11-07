# == Class: midonet_openstack::params::profile::nova::compute_vanilla
# Installs nova compute for vanilla OST installations
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
class midonet_openstack::profile::nova::compute_vanilla (
  $management_network            = $::midonet_openstack::params::network_management,
  $management_address            = ip_for_network($management_network),

  $storage_management_address    = $::midonet_openstack::params::storage_address_management,
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_address_api        = $::midonet_openstack::params::controller_address_api,

  $user                          = $::midonet_openstack::params::mysql_nova_user,
  $pass                          = $::midonet_openstack::params::mysql_nova_pass,
  $api_user                      = $::midonet_openstack::params::mysql_nova_api_user,
  $api_pass                      = $::midonet_openstack::params::mysql_nova_api_pass,

  $rabbitmq_hosts                = $::midonet_openstack::params::rabbitmq_hosts,
  $nova_rabbitmq_user            = $::midonet_openstack::params::nova_rabbitmq_user,
  $nova_rabbitmq_password        = $::midonet_openstack::params::nova_rabbitmq_password,
  $glance_api_servers            = $::midonet_openstack::params::glance_api_servers,

  $nova_debug                    = $::midonet_openstack::params::debug,
  $nova_verbose                  = $::midonet_openstack::params::verbose,
  $nova_libvirt_type             = $::midonet_openstack::params::nova_libvirt_type,

  $neutron_password              = $::midonet_openstack::params::neutron_password,

  $region_name                   = $::midonet_openstack::params::region
  ){


    $database_connection = "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova"
    $api_database_connection = "mysql+pymysql://${api_user}:${api_pass}@${controller_management_address}/nova_api"

    #midonet_openstack#::resources::firewall { 'Nova Endpoint': port => '8774', }


    unless $::midonet_openstack::params::allinone {
      class { '::nova':
        database_connection     => $database_connection,
        api_database_connection => $api_database_connection,
        rabbit_hosts            => $rabbitmq_hosts,
        rabbit_userid           => $nova_rabbitmq_user,
        rabbit_password         => $nova_rabbitmq_password,
        glance_api_servers      => join($glance_api_servers, ','),
        memcached_servers       => ["${controller_management_address}:11211"],
        verbose                 => $nova_verbose,
        debug                   => $nova_debug,
      }


      nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

      class { '::nova::network::neutron':
        neutron_password      => $neutron_password,
        neutron_region_name   => $region_name,
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
    vncproxy_host                 => $controller_address_api,
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $nova_libvirt_type,
    vncserver_listen  => $management_address,
  }

  class { '::nova::migration::libvirt':
  }

  if $::osfamily == 'RedHat' {
    package { 'device-mapper':
      ensure => latest
    }
    Package['device-mapper'] ~> Service['libvirtd'] ~> Service['nova-compute']
  }

}
