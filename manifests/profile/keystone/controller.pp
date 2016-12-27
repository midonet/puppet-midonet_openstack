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
class midonet_openstack::profile::keystone::controller (
  $default_domain      = undef,
  $using_domain_config = false,
  $token_provider      = 'uuid',
  ) {
    # Leave this included as these have some logic
    include ::openstack_integration::params
    include ::openstack_integration::config
    include ::apache

    $controller_management_address = $::midonet_openstack::params::controller_address_management
    $controller_api_address        = $::midonet_openstack::params::controller_address_api

    ##midonet_openstack#::resources::firewall { 'Keystone Public': port => '5000', }
    ##midonet_openstack#::resources::firewall { 'Keystone Private': port => '35357', }



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
    password      => $midonet_openstack::params::mysql_keystone_pass,
    allowed_hosts => '%',
  }

  class { '::keystone':
    debug               => $midonet_openstack::params::keystone_debug,
    database_connection => "mysql+pymysql://${midonet_openstack::params::mysql_keystone_user}:${midonet_openstack::params::mysql_keystone_pass}@${controller_management_address}/keystone",
    admin_token         => $midonet_openstack::params::keystone_admin_token,
    enabled             => $midonet_openstack::params::keystone_enabled,
    service_name        => 'httpd',
    default_domain      => $default_domain,
    using_domain_config => $using_domain_config,
    enable_ssl          => $::openstack_integration::config::ssl,
    public_bind_host    => $midonet_openstack::params::controller_address_api,
    admin_bind_host     => $midonet_openstack::params::controller_address_management,
    manage_policyrcd    => true,
    token_provider      => $token_provider,
    enable_fernet_setup => $enable_fernet_setup,
    memcache_servers    => ["${::midonet_openstack::params::controller_address_management}:11211"],
    require             => Class[
      'midonet_openstack::profile::memcache::memcache'
    ]
  }

  class { '::keystone::wsgi::apache':
    bind_host       => $midonet_openstack::params::controller_address_api,
    admin_bind_host => $midonet_openstack::params::controller_address_management,
    public_port     => '5000',
    admin_port      => '35357',
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
  public_url     => "http://${controller_api_address}:5000",
  admin_url      => "http://${controller_management_address}:35357",
  region         => $::midonet_openstack::params::region,
  require        => Class['keystone', 'keystone::wsgi::apache'],
  }

  class { '::openstack_extras::auth_file':
  password       => $midonet_openstack::params::keystone_admin_password,
  project_domain => 'default',
  user_domain    => 'default',
  auth_url       => "http://${controller_api_address}:5000/v3/",
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
