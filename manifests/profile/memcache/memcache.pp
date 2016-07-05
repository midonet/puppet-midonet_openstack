# The profile to install a local instance of memcache

# == Parameters
#
#  [*port*]
#    Port where memcache listens

class midonet_openstack::profile::memcache::memcache($port = '11211') {

  midonet_openstack::resources::firewall { 'Memcache': port => $port, }

  class { '::memcached':
    listen_ip => $::midonet_openstack::params::controller_address_management, #'127.0.0.1',
    tcp_port  => $port,
    udp_port  => $port,
  }
}
