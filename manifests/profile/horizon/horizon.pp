
# == Class: midonet_openstack::profile::horizon::horizon
#
#  Configure Horizon on a node
# === Parameters
#
# [*extra_aliases*]
#   List of extra serveraliases for horizon
#   (Optional) Defaults to [].
class midonet_openstack::profile::horizon::horizon(
  $extra_aliases = []
  ){
  include ::openstack_integration::params
  include ::openstack_integration::config
  include ::stdlib
  $vhost_params = { add_listen => false }
  $controller_management_address = $::midonet_openstack::params::controller_address_management
  $controller_api_address        = $::midonet_openstack::params::controller_address_api

  class { '::horizon':
    keystone_multidomain_support => true,
    server_aliases               => concat($extra_aliases,[$::fqdn,
      $::midonet_openstack::params::controller_address_management,
      $::midonet_openstack::params::controller_address_api,
      'localhost',
      '127.0.0.1']),
    cache_backend                => 'django.core.cache.backends.memcached.MemcachedCache',
    cache_server_ip              => [$::midonet_openstack::params::controller_address_management],
    cache_server_port            => '11211',
    keystone_url                 => "http://${controller_api_address}:5000/v3/",
    secret_key                   => $::midonet_openstack::params::horizon_secret_key,
    vhost_extra_params           => $vhost_params,
    keystone_default_role        => 'user',
    allowed_hosts                => $::midonet_openstack::params::horizon_allowed_hosts,
    neutron_options              => {
                                      'enable_lb'       => true,
                                      'enable_firewall' => true
                                    },
    # need to disable offline compression due to
    # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
    compress_offline             => false,
  }

}
