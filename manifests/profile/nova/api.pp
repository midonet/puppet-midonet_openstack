
# The profile to set up the Nova controller !
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
class midonet_openstack::profile::nova::api(
  $management_network            = $::midonet_openstack::params::network_management,
  $storage_management_address    = $::midonet_openstack::params::storage_address_management,
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_api_address        = $::midonet_openstack::params::controller_address_api,
  $user                          = $::midonet_openstack::params::mysql_nova_user,
  $pass                          = $::midonet_openstack::params::mysql_nova_pass,
  $api_user                      = $::midonet_openstack::params::mysql_nova_api_user,
  $api_pass                      = $::midonet_openstack::params::mysql_nova_api_pass,
  $nova_rabbitmq_user            = $::midonet_openstack::params::nova_rabbitmq_user,
  $nova_rabbitmq_password        = $::midonet_openstack::params::nova_rabbitmq_password,
  $region_name                   = $::midonet_openstack::params::region,
  $nova_password                 = $::midonet_openstack::params::nova_password,
  $mysql_nova_user               = $::midonet_openstack::params::mysql_nova_user,
  $mysql_nova_pass               = $::midonet_openstack::params::mysql_nova_password,
  $mysql_nova_api_user           = $::midonet_openstack::params::mysql_nova_api_user,
  $mysql_nova_api_pass           = $::midonet_openstack::params::mysql_nova_api_password,
  $rabbitmq_hosts                = $::midonet_openstack::params::rabbitmq_hosts,
  $glance_api_servers            = $::midonet_openstack::params::glance_api_servers,
  $nova_verbose                  = $::midonet_openstack::params::verbose,
  $nova_debug                    = $::midonet_openstack::params::debug,
  $neutron_password              = $::midonet_openstack::params::neutron_password,
  $neutron_shared_secret         = $::midonet_openstack::params::neutron_shared_secret

  ) {
  include ::openstack_integration::params
  include ::openstack_integration::config
  $management_address = ip_for_network($management_network)
  $database_connection = "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova"
  $api_database_connection = "mysql+pymysql://${api_user}:${api_pass}@${controller_management_address}/nova_api"

  class { '::nova::keystone::auth':
    public_url      => "${::openstack_integration::config::proto}://${controller_api_address}:8774/v2.1/%(tenant_id)s",
    public_url_v3   => "${::openstack_integration::config::proto}://${controller_api_address}:8774/v3/%(tenant_id)s",
    internal_url    => "${::openstack_integration::config::proto}://${controller_management_address}:8774/v2.1/%(tenant_id)s",
    internal_url_v3 => "${::openstack_integration::config::proto}://${controller_management_address}:8774/v3/%(tenant_id)s",
    admin_url       => "${::openstack_integration::config::proto}://${controller_management_address}:8774/v2.1/%(tenant_id)s",
    admin_url_v3    => "${::openstack_integration::config::proto}://${controller_management_address}:8774/v3/%(tenant_id)s",
    password        => $nova_password,
    region          => $region_name
  }

  rabbitmq_user { $nova_rabbitmq_user:
    admin    => true,
    password => $nova_rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { "${nova_rabbitmq_user}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }
  Rabbitmq_user_permissions["${nova_rabbitmq_user}@/"] -> Service<| tag == 'nova-service' |>
  class { '::nova::db::mysql':
    user          => $mysql_nova_user,
    password      => $mysql_nova_pass,
    allowed_hosts => '%',
  }
  class { '::nova::db::mysql_api':
    user          => $mysql_nova_api_user,
    password      => $mysql_nova_api_pass,
    allowed_hosts => '%',
  }
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
    require                 => Class['midonet_openstack::profile::memcache::memcache']
  }
  class { '::nova::network::neutron':
    neutron_password    => $neutron_password,
    neutron_region_name => $region_name,
    neutron_auth_url    => "http://${controller_management_address}:35357/v3",
  }
  class { '::nova::api':
    admin_password                       => $nova_password,
    auth_uri                             => "http://${controller_api_address}:5000",
    identity_uri                         => "http://${controller_management_address}:35357",
    neutron_metadata_proxy_shared_secret => $neutron_shared_secret,
    enabled                              => true,
    default_floating_pool                => 'public',
    osapi_v3                             => true,
  }
  class { '::nova::vncproxy':
    host    => $controller_api_address,
    enabled => true,
  }
  class { [
    '::nova::scheduler',
    '::nova::cert',
    '::nova::consoleauth',
    '::nova::conductor'
  ]:
    enabled => true
  }
}
