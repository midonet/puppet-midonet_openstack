class midonet_openstack::profile::neutron::controller {
  include ::openstack_integration::config

  class { 'midonet_openstack::profile::neutron::midonet':
    before => Service['neutron-server'],
  }

  package { 'python-neutron-lbaas': ensure => installed }
  package { 'python-neutron-fwaas': ensure => installed }
  package { 'openstack-neutron-ml2': ensure => absent }

rabbitmq_user { $::midonet_openstack::params::neutron_rabbitmq_user:
  admin    => true,
  password => $::midonet_openstack::params::neutron_password,
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
}

class { '::neutron':
  rabbit_user           => $::midonet_openstack::params::neutron_rabbitmq_user,
  rabbit_password       => $::midonet_openstack::params::neutron_rabbitmq_password,
  rabbit_host           => $::openstack_integration::config::rabbit_host,
  rabbit_port           => $::openstack_integration::config::rabbit_port,
  rabbit_use_ssl        => $::openstack_integration::config::ssl,
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
  database_connection => "mysql+pymysql://${::midonet_openstack::params::mysql_neutron_user}:${::midonet_openstack::params::mysql_neutron_pass}@127.0.0.1/neutron?charset=utf8",
  password            => $::midonet_openstack::params::neutron_password,
  sync_db             => false,
  api_workers         => 2,
  rpc_workers         => 2,
  auth_uri            => $::openstack_integration::config::keystone_auth_uri,
  auth_url            => $::openstack_integration::config::keystone_admin_uri,
  service_providers   => ['LOADBALANCER:Midonet:midonet.neutron.services.loadbalancer.driver.MidonetLoadbalancerDriver:default'],
}

  # Populate the DB
  class { '::neutron::db::sync':
    extra_params => '--config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/midonet/midonet.ini',
  }
  exec { 'neutron-db-sync-2':
    command     => 'neutron-db-manage --subproject networking-midonet upgrade head',
    path        => '/usr/bin',
    refreshonly => true,
    logoutput   => on_failure,
    require     => Class['::neutron::db::sync'],
  }
  Exec['neutron-db-sync-2'] ~> Service <| tag == 'neutron-db-sync-service' |>

  # Configure [nova] section in neutron.conf
  neutron_config {
    'nova/auth_url':                   value => $::openstack_integration::config::keystone_auth_uri;
    'nova/auth_plugin':                value => 'password';
    'nova/project_domain_id':          value => 'default';
    'nova/user_domain_id':             value => 'default';
    'nova/region_name':                value => $::midonet_openstack::params::region;
    'nova/project_name':               value => 'admin';
    'nova/username':                   value => 'nova';
    'nova/password':                   value => $::midonet_openstack::params::nova_password;
  }
}
