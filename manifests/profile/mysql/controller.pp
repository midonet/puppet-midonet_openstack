# == Class: midonet_openstack::profile::mysql::controller
#
#  Configure MySQL on a controller node
class midonet_openstack::profile::mysql::controller {
  class { '::mysql::server':
    override_options => {
      mysqld => { 'bind-address' => $::midonet_openstack::params::controller_address_management} #Allow remote connections
      }
    }

}
