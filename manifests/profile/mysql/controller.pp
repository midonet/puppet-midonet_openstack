# == Class: midonet_openstack::profile::mysql::controller
#
#  Configure MySQL on a controller node
# == Parameters
#
#  [*bind_address*]
#    Where should mysql listen at
class midonet_openstack::profile::mysql::controller (
  $bind_address = $::midonet_openstack::params::controller_address_management
  ){
  class { '::mysql::server':
    override_options => {
      mysqld => { bind-address => $bind_address} #Allow remote connections
    },
    # ... other class options
  }
}
