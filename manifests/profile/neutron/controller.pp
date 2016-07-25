# The midonet_openstack::profile::neutron::controller
# configures neutron in controller node , preparing it for midonet
#
#

class midonet_openstack::profile::neutron::controller {
  include ::openstack_integration::config

  $controller_management_address = $::midonet_openstack::params::controller_address_management
  $controller_api_address        = $::midonet_openstack::params::controller_address_api

  if $::osfamily == 'Debian' {
    $ml2_package = 'neutron-plugin-ml2'
  }
  if $::osfamily == 'RedHat' {
    $package_networking = 'openstack-neutron-ml2'
  }

  midonet_openstack::resources::firewall { 'Neutron': port => '9696', }

  package { 'python-neutron-lbaas': ensure => installed }
  package { 'python-neutron-fwaas': ensure => installed }
  package { 'openstack-neutron-ml2': ensure => absent }

rabbitmq_user { $::midonet_openstack::params::neutron_rabbitmq_user:
  admin    => true,
  password => $::midonet_openstack::params::neutron_rabbitmq_password,
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
  password      => $::midonet_openstack::params::mysql_neutron_pass,
  allowed_hosts => '%',
}
class { '::neutron::keystone::auth':
  password => $::midonet_openstack::params::neutron_password,
  region   => $::midonet_openstack::params::region
}



class { '::neutron':
  rabbit_user           => $::midonet_openstack::params::neutron_rabbitmq_user,
  rabbit_password       => $::midonet_openstack::params::neutron_rabbitmq_password,
  rabbit_hosts          => $::midonet_openstack::params::rabbitmq_hosts,
  rabbit_use_ssl        => $::midonet_openstack::params::rabbitmq_ssl,
  allow_overlapping_ips => true,
  core_plugin           => 'midonet.neutron.plugin_v2.MidonetPluginV2',
  service_plugins       => [
    'midonet.neutron.services.firewall.plugin.MidonetFirewallPlugin',
    'lbaas',
    'neutron.services.l3.l3_midonet.MidonetL3ServicePlugin'
    ],
  debug                 => true,
  verbose               => true,
}
class { '::neutron::client': }
class { '::neutron::server':
  database_connection => "mysql+pymysql://${::midonet_openstack::params::mysql_neutron_user}:${::midonet_openstack::params::mysql_neutron_pass}@${controller_management_address}/neutron?charset=utf8",
  password            => $::midonet_openstack::params::neutron_password,
  sync_db             => false,
  api_workers         => 2,
  rpc_workers         => 2,
  auth_uri            => "http://${controller_api_address}:5000",
  auth_url            => "http://${controller_management_address}:35357",
  service_providers   => ['LOADBALANCER:Midonet:midonet.neutron.services.loadbalancer.driver.MidonetLoadbalancerDriver:default'],
  region_name         => $::midonet_openstack::params::region,
  auth_region         => $::midonet_openstack::params::region
}



  # Configure [nova] section in neutron.conf
  neutron_config {
    'nova/auth_url':                   value => "http://${controller_api_address}:5000";
    'nova/auth_plugin':                value => 'password';
    'nova/project_domain_id':          value => 'default';
    'nova/user_domain_id':             value => 'default';
    'nova/region_name':                value => $::midonet_openstack::params::region;
    'nova/project_name':               value => 'admin';
    'nova/username':                   value => 'nova';
    'nova/password':                   value => $::midonet_openstack::params::nova_password;
  }
}
