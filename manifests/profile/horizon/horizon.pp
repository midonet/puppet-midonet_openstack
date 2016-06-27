
class midonet_openstack::profile::horizon::horizon {
  include ::openstack_integration::params
  include ::openstack_integration::config
  $vhost_params = { add_listen => false }

  notice("The value is $::midonet_openstack::params::controller_address_management")

  class { '::horizon':
    server_aliases        => [$::fqdn,
                              $::midonet_openstack::params::controller_address_management,
                              $::midonet_openstack::params::controller_address_api,
                              "localhost",
                              "127.0.0.1"],
    cache_backend         => "django.core.cache.backends.memcached.MemcachedCache",
    cache_server_ip       => ["$::midonet_openstack::params::controller_address_management"],
    cache_server_port     => '11211',
    keystone_url          => "${::openstack_integration::config::keystone_auth_uri}/v3/",
    secret_key            => $::midonet_openstack::params::horizon_secret_key,
    vhost_extra_params    => $vhost_params,
    allowed_hosts         => $::midonet_openstack::params::horizon_allowed_hosts,
    neutron_options       => {
                                "enable_lb" => true,
                              },
    # need to disable offline compression due to
    # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
    compress_offline      => false,
  }

}
