class midonet_openstack::profile::neutron::controller {
  include ::openstack_integration::config

# <<<<< BEGIN Prerequisites <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
rabbitmq_user { "${::midonet_openstack::params::neutron_rabbitmq_user}":
  admin    => true,
  password => "${::midonet_openstack::params::neutron_password}",
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
  password => "${::midonet_openstack::params::mysql_neutron_pass}",
}
class { '::neutron::keystone::auth':
  password => "${::midonet_openstack::params::neutron_password}",
}
# >>>>> END Prerequisites >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# <<<<< BEGIN networking options <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
class { '::neutron':
  rabbit_user           => "${::midonet_openstack::params::neutron_rabbitmq_user}",
  rabbit_password       => "${::midonet_openstack::params::neutron_rabbitmq_password}",
  rabbit_host           => $::openstack_integration::config::rabbit_host,
  rabbit_port           => $::openstack_integration::config::rabbit_port,
  rabbit_use_ssl        => $::openstack_integration::config::ssl,
  allow_overlapping_ips => true,
  core_plugin           => 'midonet.neutron.plugin_v2.MidonetPluginV2',
  service_plugins       => ['neutron.services.l3.l3_midonet.MidonetL3ServicePlugin'],
  debug                 => true,
  verbose               => true,
}
class { '::neutron::client': }
class { '::neutron::server':
  database_connection => "mysql+pymysql://${::midonet_openstack::params::mysql_neutron_user}:${::midonet_openstack::params::mysql_neutron_pass}@127.0.0.1/neutron?charset=utf8",
  password            => "${neutron_password}",
  sync_db             => false,
  api_workers         => 2,
  rpc_workers         => 2,
  auth_uri            => $::openstack_integration::config::keystone_auth_uri,
  auth_url            => $::openstack_integration::config::keystone_admin_uri,
}
class { '::neutron::db::sync':
  extra_params => '--config-file /etc/neutron/neutron.conf',
}
# >>>>> END networking options >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# <<<<< BEGIN LBaaS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
class { '::neutron::agents::lbaas':
  debug => true,
}
# >>>>> END LBaaS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#class { '::neutron::agents::l3':
  #debug => true,
#}
#class { '::neutron::agents::dhcp':
  #debug => true,
#}
#class { '::neutron::agents::metering':
  #debug => true,
#}
#class { '::neutron::server::notifications':
  #auth_url => $::openstack_integration::config::keystone_admin_uri,
  #password => "${::midonet_openstack::params::neutron_password}",
#}
#class { '::neutron::services::fwaas':
  #enabled => true,
  #driver  => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
#}
#include ::vswitch::ovs
}
