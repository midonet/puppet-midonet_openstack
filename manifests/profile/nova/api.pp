# The profile to set up the Nova controller !
class midonet_openstack::profile::nova::api {
  include ::openstack_integration::params
  include ::openstack_integration::config
  $management_network = $::midonet_openstack::params::network_management
  $management_address = ip_for_network($management_network)

  $storage_management_address = $::midonet_openstack::params::storage_address_management
  $controller_management_address = $::midonet_openstack::params::controller_address_management

  $user                = $::midonet_openstack::params::mysql_nova_user
  $pass                = $::midonet_openstack::params::mysql_nova_pass
  $api_user            = $::midonet_openstack::params::mysql_nova_api_user
  $api_pass            = $::midonet_openstack::params::mysql_nova_api_pass
  $database_connection = "mysql://${user}:${pass}@127.0.0.1/nova"
  $api_database_connection = "mysql://${api_user}:${api_pass}@127.0.0.1/nova_api"


  midonet_openstack::resources::firewall { 'Nova API': port => '8774', }
  midonet_openstack::resources::firewall { 'Nova Metadata': port => '8775', }
  midonet_openstack::resources::firewall { 'Nova EC2': port => '8773', }
  midonet_openstack::resources::firewall { 'Nova S3': port => '3333', }
  midonet_openstack::resources::firewall { 'Nova novnc': port => '6080', }

  rabbitmq_user { "user":
    name => "${::midonet_openstack::params::nova_rabbitmq_user}",
    admin    => true,
    password => "$::midonet_openstack::params::nova_rabbitmq_password",
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { 'nova@/':
    name => "${::midonet_openstack::params::nova_rabbitmq_user}@/",
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }

  class { '::nova::db::mysql':
    user => "${::midonet_openstack::params::mysql_nova_user}",
    password => "${::midonet_openstack::params::mysql_nova_pass}",
  }

  class { '::nova::db::mysql_api':
  user => "${::midonet_openstack::params::mysql_nova_api_user}",
  password => "${::midonet_openstack::params::mysql_nova_api_pass}",
 }

  class { '::nova::keystone::auth':
    public_url      => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_api}:8774/v2/%(tenant_id)s",
    public_url_v3   => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_api}:8774/v3/%(tenant_id)s",
    internal_url    => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_management}:8774/v2/%(tenant_id)s",
    internal_url_v3 => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_management}:8774/v3/%(tenant_id)s",
    admin_url       => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_management}:8774/v2/%(tenant_id)s",
    admin_url_v3    => "${::openstack_integration::config::proto}://${::midonet_openstack::params::controller_address_management}:8774/v3/%(tenant_id)s",
    password        => "${::midonet_openstack::params::nova_password}",
    region          => "${::midonet_openstack::params::region}"
  }


  class { '::nova':
    database_connection     => $database_connection,
    api_database_connection => $api_database_connection,
    rabbit_hosts            => $::midonet_openstack::params::rabbitmq_hosts,
    rabbit_userid           => $::midonet_openstack::params::rabbitmq_user,
    rabbit_password         => $::midonet_openstack::params::rabbitmq_password,
    glance_api_servers      => join($::midonet_openstack::params::glance_api_servers, ','),
    memcached_servers   => ["$::midonet_openstack::params::controller_address_management:11211"],
    verbose                 => $::midonet_openstack::params::verbose,
    debug                   => $::midonet_openstack::params::debug,
  }


  class { '::nova::network::neutron':
    neutron_password => $::midonet_openstack::params::neutron_password,
    neutron_region_name    => $::midonet_openstack::params::region,
    neutron_auth_url => "http://${controller_management_address}:35357/v3",
  }
  class { '::nova::api':
    admin_password                       => $::midonet_openstack::params::nova_password,
    auth_uri                             => "http://${controller_management_address}:5000",
    identity_uri                         => "http://${controller_management_address}:35357",
    neutron_metadata_proxy_shared_secret => $::midonet_openstack::params::neutron_shared_secret,
    enabled                              => true,
    default_floating_pool                => 'public',
    osapi_v3                             => true,
  }

  class { '::nova::vncproxy':
    host    => $::midonet_openstack::params::controller_address_api,
    enabled => true,
  }

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true
  }
}
