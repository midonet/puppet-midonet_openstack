# == Class: midonet_openstack::profile::mysql::controller
#
#  Configure MySQL on a controller node
class midonet_openstack::profile::mysql::controller {
  class { '::mysql::server':}
}
