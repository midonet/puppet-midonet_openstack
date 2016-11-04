# == Class: midonet_openstack::profile::neutron::controller_vanilla

# The midonet_openstack::profile::neutron::controller_vanilla
# configures neutron in controller node , vanilla openstack ( no midonet )
# == Parameters
#
#  [*controller_management_address*]
#    Management IP of controller host
#
#  [*controller_api_address*]
#    API IP of controller host
#
#  [*region_name*]
#    Openstack region name for nova
#
#  [*neutron_password*]
#    Password for neutron user
#
#  [*rabbitmq_user*]
#   Rabbitmq username
#
#  [*rabbitmq_password*]
#    Rabbitmq password
#
#  [*rabbitmq_hosts*]
#    List of rabbitmq hosts
#
#  [*rabbitmq_ssl*]
#    Is rabbitmq using ssl?
#
#  [*mysql_neutron_user*]
#    mysql neutron user
#
#  [*mysql_neutron_pass*]
#    Password for mysql neutron user
#
#  [*metadata_proxy_shared_secret*]
#    Metadata proxy shared secret
#
#  [*nova_password*]
#    Password for nova user
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



class midonet_openstack::profile::neutron::controller_vanilla(
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_api_address        = $::midonet_openstack::params::controller_address_api,
  $region_name                   = $::midonet_openstack::params::region,
  $neutron_password              = $::midonet_openstack::params::neutron_password,
  $rabbitmq_user                 = $::midonet_openstack::params::neutron_rabbitmq_user,
  $rabbitmq_password             = $::midonet_openstack::params::neutron_rabbitmq_password,
  $rabbitmq_hosts                = $::midonet_openstack::params::rabbitmq_hosts,
  $rabbitmq_ssl                  = $::midonet_openstack::params::rabbitmq_ssl,
  $mysql_neutron_user            = $::midonet_openstack::params::mysql_neutron_user,
  $mysql_neutron_pass            = $::midonet_openstack::params::mysql_neutron_pass,
  $neutron_password              = $::midonet_openstack::params::neutron_password,
  $metadata_proxy_shared_secret  = $::midonet_openstack::params::neutron_shared_secret,
  $nova_password                 = $::midonet_openstack::params::nova_password
  ) {
  include ::openstack_integration::config

  #midonet_openstack#::resources::firewall { 'Neutron': port => '9696', }

  rabbitmq_user { $rabbitmq_user:
    admin    => true,
    password => $rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { 'neutron@/':
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }
  class { '::neutron::db::mysql':
    password      => $mysql_neutron_pass,
    allowed_hosts => '%',
  }
  class { '::neutron::keystone::auth':
    password   => $neutron_password,
    region     => $region_name,
    public_url => "http://${controller_api_address}:9696",
    admin_url  => "http://${controller_management_address}:9696"
  }

  class { '::neutron':
    rabbit_user           => $rabbitmq_user,
    rabbit_password       => $rabbitmq_password,
    rabbit_hosts          => $rabbitmq_hosts,
    rabbit_use_ssl        => $rabbitmq_ssl,
    allow_overlapping_ips => true,
    core_plugin           => 'ml2',
    service_plugins       => ['router', 'metering', 'firewall'],
    debug                 => true,
    verbose               => true,
  }
  class { '::neutron::client': }
  class { '::neutron::server':
    database_connection => "mysql+pymysql://${mysql_neutron_user}:${mysql_neutron_pass}@127.0.0.1/neutron?charset=utf8",
    password            => $mysql_neutron_pass,
    sync_db             => true,
    api_workers         => 2,
    rpc_workers         => 2,
    auth_uri            => "http://${controller_api_address}:5000",
    auth_url            => "http://${controller_management_address}:35357",
    region_name         => $region_name,
    auth_region         => $region_name
  }
  class { '::vswitch::ovs':
    dkms_ensure          => false} ->
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan','flat'],
    tenant_network_types => ['vxlan','flat'],
    mechanism_drivers    => ['openvswitch'],
  } ->
  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => '127.0.0.1',
    tunnel_types     => ['vxlan'],
    manage_vswitch   => false,
  }
  class { '::neutron::agents::metadata':
    debug            => true,
    shared_secret    => $metadata_proxy_shared_secret,
    metadata_workers => 2,
    auth_region      => $region_name,
  }
  class { '::neutron::agents::l3':
    debug => true,
  }
  class { '::neutron::agents::dhcp':
    debug => true,
  }
  class { '::neutron::agents::metering':
    debug => true,
  }
  class { '::neutron::server::notifications':
    auth_url    => "http://${controller_management_address}:35357",
    password    => $nova_password,
    region_name => $region_name,
    nova_url    => "http://${controller_management_address}:8774/v2.1"
  }
  class { '::neutron::services::fwaas':
    enabled => true,
    driver  => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
  }

}
