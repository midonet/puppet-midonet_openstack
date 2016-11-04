# == Class: midonet_openstack::profile::neutron::controller

# The midonet_openstack::profile::neutron::controller
# configures neutron in controller node , preparing it for midonet
#
#
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
class midonet_openstack::profile::neutron::controller (
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
  $metadata_proxy_shared_secret  = $::midonet_openstack::params::neutron_shared_secret,
  $nova_password                 = $::midonet_openstack::params::nova_password
  ){
  include ::openstack_integration::config

  if $::osfamily == 'Debian' {
    $ml2_package      = 'neutron-plugin-ml2'
    $nova_api_service = 'nova-api'
  }
  if $::osfamily == 'RedHat' {
    $ml2_package      = 'openstack-neutron-ml2'
    $nova_api_service = 'openstack-nova-api'
  }
  ##midonet_openstack#::resources::firewall { 'Neutron': port => '9696', }
  package { 'python-neutron-lbaas': ensure => installed }
  package { 'python-neutron-fwaas': ensure => installed }

  class { '::neutron::keystone::auth':
    password   => $neutron_password,
    region     => $region_name,
    public_url => "http://${controller_api_address}:9696",
    admin_url  => "http://${controller_management_address}:9696"
  }

rabbitmq_user { $rabbitmq_user:
  admin    => true,
  password => $rabbitmq_password,
  provider => 'rabbitmqctl',
}
rabbitmq_user_permissions { "${rabbitmq_user}@/":
  configure_permission => '.*',
  write_permission     => '.*',
  read_permission      => '.*',
  provider             => 'rabbitmqctl',
}
Rabbitmq_user_permissions["${rabbitmq_user}@/"] -> Service<| tag == 'neutron-service' |>
class { '::neutron::db::mysql':
  password      => $mysql_neutron_pass,
  allowed_hosts => '%',
}

class { '::neutron':
  rabbit_user             => $rabbitmq_user,
  rabbit_password         => $rabbitmq_password,
  rabbit_hosts            => $rabbitmq_hosts,
  rabbit_use_ssl          => $rabbitmq_ssl,
  allow_overlapping_ips   => true,
  core_plugin             => 'midonet.neutron.plugin_v2.MidonetPluginV2',
  service_plugins         => [
    'midonet.neutron.services.firewall.plugin.MidonetFirewallPlugin',
    'lbaas',
    'midonet.neutron.services.l3.l3_midonet.MidonetL3ServicePlugin'
    ],
  debug                   => true,
  verbose                 => true,
  dhcp_agent_notification => false,
}
class { '::neutron::client': }

class { '::neutron::server':
  database_connection => "mysql+pymysql://${mysql_neutron_user}:${mysql_neutron_pass}@${controller_management_address}/neutron?charset=utf8",
  password            => $neutron_password,
  sync_db             => true,
  api_workers         => 2,
  rpc_workers         => 2,
  auth_uri            => "http://${controller_api_address}:5000",
  auth_url            => "http://${controller_management_address}:35357",
  service_providers   => ['LOADBALANCER:Midonet:midonet.neutron.services.loadbalancer.driver.MidonetLoadbalancerDriver:default'],
  region_name         => $region_name,
  auth_region         => $region_name
}

  # Configure [nova] section in neutron.conf
  neutron_config {
    'nova/auth_url':                   value => "http://${controller_api_address}:5000";
    'nova/auth_plugin':                value => 'password';
    'nova/project_domain_id':          value => 'default';
    'nova/user_domain_id':             value => 'default';
    'nova/region_name':                value => $region_name;
    'nova/project_name':               value => 'admin';
    'nova/username':                   value => 'nova';
    'nova/password':                   value => $nova_password;
  }
  class { '::midonet::neutron_plugin':
      midonet_api_ip    => '127.0.0.1',
      midonet_api_port  => '8181',
      keystone_username => 'neutron',
      keystone_password => $neutron_password,
      keystone_tenant   => 'services',
      sync_db           => true,
      notify            => Service[$nova_api_service,'neutron-server']
    }
}
