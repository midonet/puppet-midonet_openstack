class midonet_openstack::profile::rabbitmq::controller {

  include ::openstack_integration::params
  include ::openstack_integration::config

  if $::openstack_integration::config::ssl {
    file { '/etc/rabbitmq/ssl/private':
      ensure                  => directory,
      owner                   => 'root',
      mode                    => '0755',
      selinux_ignore_defaults => true,
      before                  => File["/etc/rabbitmq/ssl/private/${::fqdn}.pem"],
    }
    openstack_integration::ssl_key { 'rabbitmq':
      key_path => "/etc/rabbitmq/ssl/private/${::fqdn}.pem",
      require  => File['/etc/rabbitmq/ssl/private'],
      notify   => Service['rabbitmq-server'],
    }
    class { '::rabbitmq':
      package_provider      => $::package_provider,
      delete_guest_user     => $midonet_openstack::params::rabbitmq_delete_guest_user,
      ssl                   => $midonet_openstack::params::rabbitmq_ssl,
      ssl_only              => $midonet_openstack::params::rabbitmq_ssl_only,
      ssl_cacert            => $::openstack_integration::params::ca_bundle_cert_path,
      ssl_cert              => $::openstack_integration::params::cert_path,
      ssl_key               => "/etc/rabbitmq/ssl/private/${::fqdn}.pem",
      environment_variables => $::openstack_integration::config::rabbit_env,
      repos_ensure          => $midonet_openstack::params::rabbitmq_repos_ensure,
    }
  } else {
    class { '::rabbitmq':
      package_provider      => $::package_provider,
      delete_guest_user     => $midonet_openstack::params::rabbitmq_delete_guest_user,
      environment_variables => $::openstack_integration::config::rabbit_env,
    }
  }
  rabbitmq_vhost { '/':
  provider => 'rabbitmqctl',
  require  => Class['::rabbitmq'],
  }
}
