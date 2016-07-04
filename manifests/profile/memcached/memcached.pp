# The profile to install a local instance of memcache
class midonet_openstack::profile::memcached::memcached($port = '11211') {
  class { 'memcached':
    listen_ip => $::midonet_openstack::params::controller_address_management, #'127.0.0.1',
    tcp_port  => $port,
    udp_port  => $port,
  }
}
