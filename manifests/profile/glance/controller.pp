# == Class: midonet_openstack::profile::glance::controller
#
#  Configure the Glance image service on a controller node
#
# === Parameters
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
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
class midonet_openstack::profile::glance::controller (
  $backend                       = 'file',
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_api_address        = $::midonet_openstack::params::controller_address_api,
  $crt_file                      = $::openstack_integration::params::cert_path,
  $glance_ssl                    = $::midonet_openstack::params::glance_ssl,
  $rabbitmq_user                 = $::midonet_openstack::params::neutron_rabbitmq_user,
  $rabbitmq_password             = $::midonet_openstack::params::neutron_rabbitmq_password,
  $rabbitmq_hosts                = $::midonet_openstack::params::rabbitmq_hosts,
  $rabbitmq_ssl                  = $::midonet_openstack::params::rabbitmq_ssl,
  $mysql_glance_user             = $::midonet_openstack::params::mysql_glance_user,
  $mysql_glance_pass             = $::midonet_openstack::params::mysql_glance_pass,
  $glance_keystone_pass          = $::midonet_openstack::params::glance_password,
  $region_name                   = $::midonet_openstack::params::region,
  $keystone_auth_uri             = $::openstack_integration::config::keystone_auth_uri,
  $glance_debug                  = $::midonet_openstack::params::glance_debug,
  $keystone_protocol             = $::openstack_integration::config::proto,
  ) {
    include ::openstack_integration::config
    include ::openstack_integration::params



    ##midonet_openstack#::resources::firewall { 'Glance API': port => '9292', }
    ##midonet_openstack#::resources::firewall { 'Glance Registry': port => '9191', }

    if $glance_ssl {
      openstack_integration::ssl_key { 'glance':
        notify => [Service['glance-api'], Service['glance-registry']],
      }
      Package<| tag == 'glance-package' |> -> File['/etc/glance/ssl']
      $key_file  = "/etc/glance/ssl/private/${::fqdn}.pem"
      $crt_file = $crt_file
      Exec['update-ca-certificates'] ~> Service['glance-api']
      Exec['update-ca-certificates'] ~> Service['glance-registry']
    } else {
      $key_file = undef
      $crt_file  = undef
    }

    rabbitmq_user { $rabbitmq_user:
      admin    => true,
      password => $rabbitmq_password,
      provider => 'rabbitmqctl',
      require  => Class['::rabbitmq'],
      before   => Service['glance-api','glance-registry']
    }
    rabbitmq_user_permissions { "${rabbitmq_user}@/":
      configure_permission => '.*',
      write_permission     => '.*',
      read_permission      => '.*',
      provider             => 'rabbitmqctl',
      require              => Class['::rabbitmq'],
      before               => Service['glance-api','glance-registry']
    }

    class { '::glance::db::mysql':
      password      => $mysql_glance_pass,
      allowed_hosts => '%',
    }
    include ::glance
    include ::glance::client
    class { '::glance::keystone::auth':
      password   => $glance_keystone_pass,
      region     => $region_name,
      public_url => "http://${controller_api_address}:9292",
      admin_url  => "http://${controller_management_address}:9292"
    }
    case $backend {
      'file': {
        include ::glance::backend::file
        $backend_store = ['file']
      }
      'rbd': {
        class { '::glance::backend::rbd':
          rbd_store_user => 'openstack',
          rbd_store_pool => 'glance',
        }
        $backend_store = ['rbd']
        # make sure ceph pool exists before running Glance API
        Exec['create-glance'] -> Service['glance-api']
      }
      'swift': {
        Service<| tag == 'swift-service' |> -> Service['glance-api']
        $backend_store = ['swift']
        class { '::glance::backend::swift':
          swift_store_user                    => 'services:glance',
          swift_store_key                     => 'a_big_secret',
          swift_store_create_container_on_put => 'True',
          swift_store_auth_address            => "${keystone_auth_uri}/v3",
          swift_store_auth_version            => '3',
        }
      }
      default: {
        fail("Unsupported backend (${backend})")
      }
    }
    $http_store = ['http']
    $glance_stores = concat($http_store, $backend_store)
    class { '::glance::api':
      debug                     => $glance_debug,
      database_connection       => "mysql+pymysql://${mysql_glance_user}:${mysql_glance_pass}@${controller_management_address}/glance?charset=utf8",
      keystone_password         => $glance_keystone_pass,
      workers                   => 2,
      stores                    => $glance_stores,
      default_store             => $backend,
      bind_host                 => $controller_management_address,
      auth_uri                  => "http://${controller_api_address}:5000",
      identity_uri              => "http://${controller_api_address}:35357",
      registry_client_protocol  => $keystone_protocol,
      registry_client_cert_file => $crt_file,
      registry_client_key_file  => $key_file,
      registry_host             => $controller_management_address,
      cert_file                 => $crt_file,
      key_file                  => $key_file,
      os_region_name            => $region_name,
    }
    class { '::glance::registry':
      debug               => $glance_debug,
      database_connection => "mysql+pymysql://${mysql_glance_user}:${mysql_glance_pass}@${controller_management_address}/glance?charset=utf8",
      keystone_password   => $glance_keystone_pass,
      bind_host           => $controller_management_address,
      workers             => 2,
      auth_uri            => "http://${controller_api_address}:5000",
      identity_uri        => "http://${controller_management_address}:35357",
      cert_file           => $crt_file,
      key_file            => $key_file,
      os_region_name      => $region_name,
    }
    class { '::glance::notify::rabbitmq':
      rabbit_userid       => $rabbitmq_user,
      rabbit_password     => $rabbitmq_password,
      rabbit_hosts        => $rabbitmq_hosts,
      notification_driver => 'messagingv2',
      rabbit_use_ssl      => $rabbitmq_ssl
  }
}
