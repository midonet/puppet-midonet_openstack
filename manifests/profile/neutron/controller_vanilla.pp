# The midonet_openstack::profile::neutron::controller_vanilla
# configures neutron in controller node , vanilla openstack ( no midonet )





class midonet_openstack::profile::neutron::controller_vanilla {
  include ::openstack_integration::config

  $controller_management_address = $::midonet_openstack::params::controller_address_management
  $controller_api_address        = $::midonet_openstack::params::controller_address_api
  midonet_openstack::resources::firewall { 'Neutron': port => '9696', }

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
    core_plugin           => 'ml2',
    service_plugins       => ['router', 'metering', 'firewall'],
    debug                 => true,
    verbose               => true,
  }
  class { '::neutron::client': }
  class { '::neutron::server':
    database_connection => "mysql+pymysql://${::midonet_openstack::params::mysql_neutron_user}:${::midonet_openstack::params::mysql_neutron_pass}@${controller_management_address}/neutron?charset=utf8",
    password            => $::midonet_openstack::params::neutron_password,
    sync_db             => true,
    api_workers         => 2,
    rpc_workers         => 2,
    auth_uri            => "http://${controller_api_address}:5000",
    auth_url            => "http://${controller_management_address}:35357",
    region_name         => $::midonet_openstack::params::region,
    auth_region         => $::midonet_openstack::params::region
  }
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan'],
    tenant_network_types => ['vxlan'],
    mechanism_drivers    => ['openvswitch'],
  }
  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => true,
    local_ip         => '127.0.0.1',
    tunnel_types     => ['vxlan'],
  }
  class { '::neutron::agents::metadata':
    debug            => true,
    shared_secret    => $::midonet_openstack::params::neutron_shared_secret,
    metadata_workers => 2,
    auth_region      => $::midonet_openstack::params::region,
  }
  class { '::neutron::agents::lbaas':
    debug => true,
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
    password    => $::midonet_openstack::params::nova_password,
    region_name => $::midonet_openstack::params::region
  }
  class { '::neutron::services::fwaas':
    enabled => true,
    driver  => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
  }
  include ::vswitch::ovs
}
