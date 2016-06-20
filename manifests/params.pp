# [*region*]
#   The region name to set up the midonet_openstack services.
#
# == Networks
# [*network_api*]
#   The CIDR of the api network. This is the network that all public
#   api calls are made on as well as the network to access Horizon.
#
# [*networks*]
#   (optional) Hash of neutron networks. Example =
#     {
#       'public' => {
#         'tenant_name'              => 'services'
#         'provider_network_type'    => 'gre'
#         'router_external'          => true
#         'provider_segmentation_id' => 3604
#         'shared'                   => true
#       }
#     }
#   Consult the neutron_network documentation for more information.
#   Defaults to {}.
#
# [*subnets*]
#   (optional) Hash of neutron subnets. Example =
#     {
#       '192.168.22.0/24' => {
#         'cidr'             => '192.168.22.0/24'
#         'ip_version'       => '4'
#         'gateway_ip'       => '192.168.22.2'
#         'enable_dhcp'      => false
#         'network_name'     => 'public'
#         'tenant_name'      => 'services'
#         'allocation_pools' => ['start=192.168.22.100end=192.168.22.200']
#         'dns_nameservers'  => [192.168.22.2]
#       }
#     }
#   Consult the neutron_subnet documentation for more information.
#   Defaults to {}.
#
# [*routers*]
#   (optional) Hash of neutron routers. Example =
#     {
#       'test' => {
#         'tenant_name'          => 'test'
#         'gateway_network_name' => 'public'
#       }
#     }
#   Consult the neutron_router documentation for more information.
#   Defaults to {}.
#
# [*router_interfaces*]
#   (optional) Hash of neutron router interfaces. The key has the form
#   tenant =subnet where the subnet is one of the subnets given by the
#   $subnets parameter. Example =
#     {
#       'test =10.0.0.0/24' => {
#         ensure => present
#        }
#     }
#   Consult the neutron_router_interface documentation for more
#   information.
#   Defaults to {}.
#
# [*network_external*]
#   The CIDR of the external network. May be the same as network_api.
#   This is the network that floating IP addresses are allocated in
#   to allow external access to virtual machine instances.
#
# [*network_management*]
#   The CIDR of the management network.
#
# [*network_data*]
#   The CIDR of the data network. May be the same as network_management.
#
# == Fixed IPs (controllers)
# [*controller_address_api*]
#   The API IP address of the controller node. Must be in the network_api CIDR.
#
# [*controller_address_management*]
#   The management IP address of the controller node. Must be in the network_management CIDR.
#
# [*storage_address_api*]
#   The API IP address of the storage node. Must be in the network_api CIDR.
#
# [*storage_address_management*]
#   The management IP address of the storage node. Must be in the network_management CIDR.
#
# == Database
# [*mysql_root_password*]
#   The root password for the MySQL database.
#
# [*mysql_service_password*]
#   The MySQL shared password for all of the midonet_openstack services.
#
# [*mysql_allowed_hosts*]
#   Array of hosts that are allowed to access the MySQL database. Should include all of the network_management CIDR.
#   Example configuration = ['localhost' '127.0.0.1' '172.16.33.%']
#
# [*mysql_user_keystone*]
#   The database username for keystone service.
#
# [*mysql_pass_keystone*]
#   The database password for keystone service.
#
# [*mysql_user_cinder*]
#   The database username for cinder service.
#
# [*mysql_pass_cinder*]
#   The database password for cinder service.
#
# [*mysql_user_glance*]
#   The database username for glance service.
#
# [*mysql_pass_glance*]
#   The database password for glance service.
#
# [*mysql_user_nova*]
#   The database username for nova service.
#
# [*mysql_pass_nova*]
#   The database password for nova service.
#
# [*mysql_user_neutron*]
#   The database username for neutron service.
#
# [*mysql_pass_neutron*]
#   The database password for neutron service.
#
# [*mysql_user_heat*]
#   The database username for heat service.
#
# [*mysql_pass_heat*]
#   The database password for heat service.
#
# == RabbitMQ
# [*rabbitmq_hosts*]
#   The host list for the RabbitMQ service.
#
# [*rabbitmq_user*]
#   The username for the RabbitMQ queues.
#
# [*rabbitmq_password*]
#   The password for accessing the RabbitMQ queues.
#
# == Keystone
# [*keystone_admin_token*]
#   The global administrative token for the Keystone service.
#
# [*keystone_admin_email*]
#   The e-mail address of the Keystone administrator.
#
# [*keystone_admin_password*]
#   The password for keystone user in Keystone.
#
# [*keystone_tenants*]
#   The intial keystone tenants to create. Should be a Hash in the form of =
#   {'tenant_name1' => { 'descritpion' => 'Tenant Description 1'}
#    'tenant_name2' => {'description' => 'Tenant Description 2'}}
#
# [*keystone_users*]
#   The intial keystone users to create. Should be a Hash in the form of =
#   {'user1' => {'password' => 'somepass1' 'tenant' => 'some_preexisting_tenant'
#                'email' => 'foo@example.com' 'admin'  =>  'true'}
#   'user2' => {'password' => 'somepass2' 'tenant' => 'some_preexisting_tenant'
#                'email' => 'foo2@example.com' 'admin'  =>  'false'}}
#
# [*keystone_use_httpd*]
#   Whether to set up an Apache web service with mod_wsgi or to use the default
#   Eventlet service. If false the default from $keystone_params_service_name
#   will be used which will be the default Eventlet service. Set to true to
#   configure an Apache web service using mod_wsgi which is currently the only
#   web service configuration available through the keystone module.
#   Defaults to false.
#
# == Glance
# [*images*]
#  (optional) Hash of glance_images resources. Example =
#    {
#      'Cirros' => {
#        'container_format' => 'bare'
#        'disk_format'      => 'qcow2'
#        'source'           => 'http =//download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img'
#      }
#   }
#  Consult the glance_image documentation for more information.
#
# [*glance_password*]
#   The password for the glance user in Keystone.
#
# [*glance_api_servers*]
#   Array of api servers with port setting
#   Example configuration = ['172.16.33.4 =9292']
#
# ==Cinder
# [*cinder_password*]
#   The password for the cinder user in Keystone.
#
# [*cinder_volume_size*]
#   The size of the Cinder loopback storage device. Example = '8G'.
#
# == Swift
# [*swift_password*]
#    The password for the swift user in Keystone.
#
# [*swift_hash_suffix*]
#   The hash suffix for Swift ring communication.
#
# == Nova
# [*nova_libvirt_type*]
#   The type of hypervisor to use for Nova. Typically 'kvm' for
#   hardware accelerated virtualization or 'qemu' for software virtualization.
#
# [*nova_password*]
#   The password for the nova user in Keystone.
#
# == Neutron
# [*neutron_password*]
#   The password for the neutron user in Keystone.
#
# [*neutron_shared_secret*]
#   The shared secret to allow for communication between Neutron and Nova.
#
# [*neutron_core_plugin*]
#   The core_plugin for the neutron service
#
# [*neutron_service_plugins*]
#   The service_plugins for neutron service
#
# [*plumgrid_director_vip*]
#   IP address of the PLUMgrid Director Server
#
# [*plumgrid_username*]
#   PLUMgrid platform username
#
# [*plumgrid_password*]
#   PLUMgrid platform password
#
# [*neutron_tunneling*] (Deprecated)
#   Boolean. Whether to enable Neutron tunneling.
#   Default to true.
#
# [*neutron_tunnel_types*] (Deprecated)
#   Array. Tunnel types to use
#   Defaults to ['gre']
#
# [*neutron_tenant_network_type*] (Deprecated)
#   Array. Tenant network type.
#   Defaults to ['gre']
#
# [*neutron_type_drivers*] (Deprecated)
#   Array. Neutron type drivers to use.
#   Defaults to ['gre']
#
# [*neutron_mechanism_drivers*] (Deprecated)
#   Defaults to ['openvswitch'].
#
# [*neutron_tunnel_id_ranges*] (Deprecated)
#   Neutron tunnel id ranges.
#   Defaults to ['1 =1000']
#
# == Ceilometer
# [*ceilometer_address_management*]
#   The management IP address of the ceilometer node. Must be in the network_management CIDR.
#
# [*ceilometer_mongo_username*]
#   The username for the MongoDB Ceilometer user.
#
# [*ceilometer_mongo_password*]
#   The password for the MongoDB Ceilometer user.
#
# [*ceilometer_password*]
#   The password for the ceilometer user in Keystone.
#
# [*ceilometer_meteringsecret*]
#   The shared secret to allow communication betweek Ceilometer and other
#   midonet_openstack services.
#
# == Heat
# [*heat_password*]
#   The password for the heat user in Keystone.
#
# [*heat_encryption_key*]
#   The encyption key for the shared heat services.
#
# == Horizon
# [*horizon_secret_key*]
#   The secret key for the Horizon service.
#
# [*allowed_hosts*]
#   List of hosts which will be set as value of ALLOWED_HOSTS
#   parameter in settings_local.py. This is used by Django for
#   security reasons. Can be set to * in environments where security is
#   deemed unimportant.
#
# [*server_aliases*]
#   List of names which should be defined as ServerAlias directives
#   in vhost.conf.
#
# == Log levels
# [*verbose*]
#   Boolean. Determines if verbose is enabled for all midonet_openstack services.
#
# [*debug*]
#   Boolean. Determines if debug is enabled for all midonet_openstack services.
#
# == Tempest
# [*tempest_configure_images*]
#   Boolean. Whether Tempest should configure images.
#
# [*tempest_image_name*]
#   The name of the primary image to use for tests.
#
# [*tempest_image_name_alt*]
#   The name of the secondary image to use for tests. If the same as the
#   tempest_image_primary some tests will be disabled.
#
# [*tempest_username*]
#   The login username to run tempest tests.
#
# [*tempest_username_alt*]
#   The alternate login username for tempest tests.
#
# [*tempest_username_admin*]
#   The uername for the Tempest admin user.
#
# [*tempest_configure_network*]
#   Boolean. If Tempest should configure test networks.
#
# [*tempest_public_network_name*]
#   The name of the public neutron network for Tempest to connect to.
#
# [*tempest_cinder_available*]
#   Boolean. If Cinder services are available.
#
# [*tempest_glance_available*]
#   Boolean. If Glance services are available.
#
# [*tempest_horizon_available*]
#   Boolean. If Horizon is available.
#
# [*tempest_nova_available*]
#   Boolean. If Nova services are available.
#
# [*tempest_neutron_available*]
#   Boolean. If Neutron services are availale.
#
# [*tempest_heat_available*]
#   Boolean. If Heat services are available.
#
# [*tempest_swift_available*]
#   Boolean. If Swift services are available.
#
class midonet_openstack::params {
  $use_hiera = true
  $region = undef
  $network_api = undef
  $networks = undef
  $subnets = undef
  $routers = undef
  $router_interfaces = undef
  $network_external = undef
  $network_management = undef
  $network_data = undef
  $network_external_ippool_start = undef
  $network_external_ippool_end = undef
  $network_external_gateway = undef
  $network_external_dns = undef
  $network_neutron_private = undef
  $controller_address_api = undef
  $controller_address_management = undef
  $storage_address_api = undef
  $storage_address_management = undef

  $mysql_root_password = undef
  $mysql_service_password = undef
  $mysql_allowed_hosts = undef
  $mysql_user_keystone = 'keystone'
  $mysql_pass_keystone = 'keystone_db_pass'
  $mysql_user_cinder = undef
  $mysql_pass_cinder = undef
  $mysql_user_glance = undef
  $mysql_pass_glance = undef
  $mysql_user_nova = undef
  $mysql_pass_nova = undef
  $mysql_user_neutron = undef
  $mysql_pass_neutron = undef
  $mysql_user_heat = undef
  $mysql_pass_heat = undef

  $rabbitmq_hosts = undef
  $rabbitmq_user = undef
  $rabbitmq_password = undef
  $rabbitmq_delete_guest_user = true
  $rabbitmq_ssl = true
  $rabbitmq_ssl_only = true

  $keystone_admin_token = 'admin_token'
  $keystone_admin_email = 'admin@example.tld'
  $keystone_admin_password = 'admin'
  $keystone_tenants = undef
  $keystone_users = undef
  $keystone_use_httpd = false
  $keystone_debug = true
  $keystone_enabled = true

  $glance_password = undef
  $glance_api_servers = undef
  $images = undef
  $cinder_password = undef
  $cinder_volume_size = undef
  $swift_password = undef
  $swift_hash_suffix = undef
  $nova_libvirt_type = undef
  $nova_password = undef
  $neutron_password = undef
  $neutron_shared_secret = undef
  $neutron_core_plugin = undef
  $neutron_service_plugins = undef
  $plumgrid_director_vip = undef
  $plumgrid_username = undef
  $plumgrid_password = undef
  $neutron_tunneling = true
  $neutron_tunnel_types = ['gre']
  $neutron_tenant_network_type = ['gre']
  $neutron_type_drivers = ['gre']
  $neutron_mechanism_drivers = ['openvswitch']
  $neutron_tunnel_id_ranges = ['1:1000']
  $ceilometer_address_management = undef
  $ceilometer_mongo_username = undef
  $ceilometer_mongo_password = undef
  $ceilometer_password = undef
  $ceilometer_meteringsecret = undef
  $heat_password = undef
  $heat_encryption_key = undef
  $horizon_secret_key = undef
  $horizon_allowed_hosts = undef
  $horizon_server_aliases = undef
  $tempest_configure_images    = undef
  $tempest_image_name          = undef
  $tempest_image_name_alt      = undef
  $tempest_username            = undef
  $tempest_username_alt        = undef
  $tempest_username_admin      = undef
  $tempest_configure_network   = undef
  $tempest_public_network_name = undef
  $tempest_cinder_available    = undef
  $tempest_glance_available    = undef
  $tempest_horizon_available   = undef
  $tempest_nova_available      = undef
  $tempest_neutron_available   = undef
  $tempest_heat_available      = undef
  $tempest_swift_available     = undef
  $verbose = undef
}
