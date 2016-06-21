class midonet_openstack::profile::firewall::firewall {
  class { '::midonet_openstack::profile::firewall::pre': }
  class { '::midonet_openstack::profile::firewall::post': }
}
