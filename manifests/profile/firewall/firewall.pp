class midonet_openstack::profile::firewall {
  class { '::midonet_openstack::profile::firewall::pre': }
  class { '::midonet_openstack::profile::firewall::post': }
}
