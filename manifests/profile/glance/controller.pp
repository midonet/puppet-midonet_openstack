# == Class: midonet_openstack::profile::glance::controller
#
#  Configure the Glance image service on a controller node
#
# === Parameters
#
# [*backend*]
#   Backend to be used by Glance.
#   (Optional) Defaults to 'file'.
class midonet_openstack::profile::glance::controller (
  $backend = 'file',
  ) {
    include ::openstack_integration::config
    include ::openstack_integration::params

    $controller_management_address = $::midonet_openstack::params::controller_address_management
    $controller_api_address        = $::midonet_openstack::params::controller_address_api

    midonet_openstack::resources::firewall { 'Glance API': port => '9292', }
    midonet_openstack::resources::firewall { 'Glance Registry': port => '9191', }

    if $::midonet_openstack::params::glance_ssl {
      openstack_integration::ssl_key { 'glance':
        notify => [Service['glance-api'], Service['glance-registry']],
      }
      Package<| tag == 'glance-package' |> -> File['/etc/glance/ssl']
      $key_file  = "/etc/glance/ssl/private/${::fqdn}.pem"
      $crt_file = $::openstack_integration::params::cert_path
      Exec['update-ca-certificates'] ~> Service['glance-api']
      Exec['update-ca-certificates'] ~> Service['glance-registry']
    } else {
      $key_file = undef
      $crt_file  = undef
    }

    rabbitmq_user { $midonet_openstack::params::glance_rabbitmq_user:
      admin    => true,
      password => $midonet_openstack::params::glance_rabbitmq_password,
      provider => 'rabbitmqctl',
      require  => Class['::rabbitmq'],
    }
    rabbitmq_user_permissions { 'glance@/':
      configure_permission => '.*',
      write_permission     => '.*',
      read_permission      => '.*',
      provider             => 'rabbitmqctl',
      require              => Class['::rabbitmq'],
    }

    class { '::glance::db::mysql':
      password      => $midonet_openstack::params::mysql_glance_pass,
      allowed_hosts => '%',
    }
    include ::glance
    include ::glance::client
    class { '::glance::keystone::auth':
      password   => $midonet_openstack::params::glance_password,
      region     => $midonet_openstack::params::region,
      public_url => $controller_api_address,
      admin_url  => $controller_management_address,
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
          swift_store_auth_address            => "${::openstack_integration::config::keystone_auth_uri}/v3",
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
      debug                     => $midonet_openstack::params::glance_debug,
      database_connection       => "mysql+pymysql://${::midonet_openstack::params::mysql_glance_user}:${midonet_openstack::params::mysql_glance_pass}@127.0.0.1/glance?charset=utf8",
      keystone_password         => $midonet_openstack::params::glance_password,
      workers                   => 2,
      stores                    => $glance_stores,
      default_store             => $backend,
      bind_host                 => $controller_management_address,
      auth_uri                  => "http://${controller_api_address}:5000",
      identity_uri              => "http://${controller_api_address}:35357",
      registry_client_protocol  => $::openstack_integration::config::proto,
      registry_client_cert_file => $crt_file,
      registry_client_key_file  => $key_file,
      registry_host             => $controller_management_address,
      cert_file                 => $crt_file,
      key_file                  => $key_file,
      os_region_name            => $midonet_openstack::params::region,
    }
    class { '::glance::registry':
      debug               => $midonet_openstack::params::glance_debug,
      database_connection => "mysql+pymysql://${midonet_openstack::params::mysql_glance_user}:${midonet_openstack::params::mysql_glance_pass}@127.0.0.1/glance?charset=utf8",
      keystone_password   => $midonet_openstack::params::glance_password,
      bind_host           => $controller_management_address,
      workers             => 2,
      auth_uri            => "http://${controller_api_address}:5000",
      identity_uri        => "http://${controller_management_address}:35357",
      cert_file           => $crt_file,
      key_file            => $key_file,
      os_region_name      => $midonet_openstack::params::region,
    }
    class { '::glance::notify::rabbitmq':
      rabbit_userid       => $midonet_openstack::params::glance_rabbitmq_user,
      rabbit_password     => $midonet_openstack::params::glance_rabbitmq_password,
      rabbit_hosts        => $midonet_openstack::params::rabbitmq_hosts,
      notification_driver => 'messagingv2',
      rabbit_use_ssl      => $midonet_openstack::params::rabbitmq_ssl
  }
}
