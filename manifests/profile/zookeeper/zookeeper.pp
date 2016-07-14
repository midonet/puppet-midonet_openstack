# == Class: midonet_openstack::profile::zookeeper::zookeeper
#
#  Configure Zookeeper
# == Parameters
#
#  [*id*]
#    Zookeeper Host Id
#  [*client_ip*]
#    Zookeeper client ip
#  [*zk_servers*]
#    List of zookeeper servers
class midonet_openstack::profile::zookeeper::zookeeper(
  $id                   = 1,
  $client_ip            = $::ipaddress_eth0,
  $zk_servers           = zookeeper_servers($midonet_openstack::params::zookeeper_servers)
  ) {

    if $::osfamily == 'RedHat'
    {
      $zk_packages = ['zookeeper']
      class {'::zookeeper':
        servers          => $zk_servers,
        id               => $id,
        cfg_dir          => '/etc/zookeeper',
        client_ip        => $client_ip,
        packages         => $zk_packages,
        service_name     => 'zookeeper',
        require          => [ File['/usr/java/default'], Class['midonet::repository'] ],
        service_provider => 'init'

      }
    }
    elsif $::osfamily == 'Debian'
    {
      $zk_packages = ['zookeeper','zookeeperd']

      class {'::zookeeper':
        servers      => $zk_servers,
        id           => $id,
        cfg_dir      => '/etc/zookeeper',
        client_ip    => $client_ip,
        packages     => $zk_packages,
        service_name => 'zookeeper',
        require      => [ File['/usr/java/default'], Class['midonet::repository'] ],
      }
    }
    else {
      fail("Unsupported Operating System Family ${::osfamily}")
    }

}
