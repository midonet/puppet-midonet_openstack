# == Class: midonet_openstack::profile::midojava::psp
#
#  Configure Python Software Properties
class midonet_openstack::profile::midojava::psp {

    if $::osfamily == 'Debian' and $::lsbdistrelease == '14.04' {
      package { 'python-software-properties':
       ensure => installed
     }
   }
}
