# The midonet_openstack::profile::firewall::firewall
# configures basic firewall rules to allow ssh access, and management
# network unrestricted access


class midonet_openstack::profile::firewall::firewall {
  class { '::midonet_openstack::profile::firewall::pre': }
  class { '::midonet_openstack::profile::firewall::post': }
}
