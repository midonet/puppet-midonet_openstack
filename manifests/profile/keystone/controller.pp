# Configure the Keystone service
#
# [*default_domain*]
#   (optional) Define the default domain id.
#   Set to 'undef' for 'Default' domain.
#   Default to undef.
#
# [*using_domain_config*]
#   (optional) Eases the use of the keystone_domain_config resource type.
#   It ensures that a directory for holding the domain configuration is present
#   and the associated configuration in keystone.conf is set up right.
#   Defaults to false
#
# [*token_provider*]
#   (optional) Define the token provider to use.
#   Default to 'uuid'.
#
class midonet_openstack::profile::keystone::controller (
  $default_domain      = undef,
  $using_domain_config = false,
  $token_provider      = 'uuid',
  ) {
    # Leave this included as these have some logic
    include ::openstack_integration::params
    include ::openstack_integration::config
    include ::apache

    midonet_openstack::resources::firewall { 'Keystone Public': port => '5000', }
    midonet_openstack::resources::firewall { 'Keystone Private': port => '35357', }



  if $::openstack_integration::config::ssl {
    openstack_integration::ssl_key { 'keystone':
      notify  => Service['httpd'],
      require => Package['keystone'],
    }
    Exec['update-ca-certificates'] ~> Service['httpd']
  }

  if $token_provider == 'fernet' {
    $enable_fernet_setup = true
    } else {
    $enable_fernet_setup = false
  }

  class { '::keystone::client': }

  class { '::keystone::cron::token_flush': }

  class { '::keystone::db::mysql':
    password => $midonet_openstack::params::mysql_keystone_pass,
  }

  class { '::keystone':
    debug               => $midonet_openstack::params::keystone_debug,
    database_connection => "mysql+pymysql://${midonet_openstack::params::mysql_keystone_user}:${midonet_openstack::params::mysql_keystone_pass}@127.0.0.1/keystone",
    admin_token         => $midonet_openstack::params::keystone_admin_token,
    enabled             => $midonet_openstack::params::keystone_enabled,
    service_name        => 'httpd',
    default_domain      => $default_domain,
    using_domain_config => $using_domain_config,
    enable_ssl          => $::openstack_integration::config::ssl,
    public_bind_host    => $::openstack_integration::config::host,
    admin_bind_host     => $::openstack_integration::config::host,
    manage_policyrcd    => true,
    token_provider      => $token_provider,
    enable_fernet_setup => $enable_fernet_setup,
    memcache_servers    => ["${::midonet_openstack::params::controller_address_management}:11211"],
    require             => Class['midonet_openstack::profile::memcache::memcache']
  }

  class { '::keystone::wsgi::apache':
    bind_host       => $::openstack_integration::config::ip_for_url,
    admin_bind_host => $::openstack_integration::config::ip_for_url,
    ssl             => $::openstack_integration::config::ssl,
    ssl_key         => "/etc/keystone/ssl/private/${::fqdn}.pem",
    ssl_cert        => $::openstack_integration::params::cert_path,
    workers         => 2,
  }
  # Workaround to purge Keystone vhost that is provided & activated by default with running
  # Canonical packaging (called 'keystone').
  if ($::operatingsystem == 'Ubuntu') and (versioncmp($::operatingsystemmajrelease, '16') >= 0) {
  ensure_resource('file', '/etc/apache2/sites-available/keystone.conf', {
  'ensure'  => 'absent',
  })
  ensure_resource('file', '/etc/apache2/sites-enabled/keystone.conf', {
  'ensure'  => 'absent',
  })

  Package['keystone'] -> File['/etc/apache2/sites-available/keystone.conf']
  -> File['/etc/apache2/sites-enabled/keystone.conf'] ~> Anchor['keystone::install::end']
  }

  class { '::keystone::roles::admin':
  email    => $midonet_openstack::params::keystone_admin_email,
  password => $midonet_openstack::params::keystone_admin_password,
  }

  class { '::keystone::endpoint':
  default_domain => $default_domain,
  public_url     => $::openstack_integration::config::keystone_auth_uri,
  admin_url      => $::openstack_integration::config::keystone_admin_uri,
  region         => $::midonet_openstack::params::region,
  require        => Class['keystone', 'keystone::wsgi::apache'],
  }

  class { '::openstack_extras::auth_file':
  password       => $midonet_openstack::params::keystone_admin_password,
  project_domain => 'default',
  user_domain    => 'default',
  auth_url       => "${::openstack_integration::config::keystone_auth_uri}/v3/",
  region_name    => $midonet_openstack::params::region,
  }

  $tenants = $::midonet_openstack::params::keystone_tenants
  $users   = $::midonet_openstack::params::keystone_users
  create_resources('keystone_tenant', $tenants)

  # Create the 'user' role so we can assign it later to the the users
  keystone_role { 'user':
                  ensure => present,
                }

  create_resources('midonet_openstack::resources::keystone_user', $users)

}
