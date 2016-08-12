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
  ){
    midonet_openstack::resources::firewall { 'Zookeeper': port => '2181'}
    if $::osfamily == 'RedHat'
    {
      $zk_packages = ['zookeeper']

      class {'::zookeeper':
        servers             => $zk_servers,
        id                  => $id,
        cfg_dir             => '/etc/zookeeper',
        client_ip           => $client_ip,
        packages            => $zk_packages,
        service_name        => 'zookeeper',
        manage_service      => false,
        manage_service_file => false,
      }
      contain '::zookeeper'

      file { '/lib/systemd/system/zookeeper.service':
        ensure  => file,
        content => template('midonet_openstack/zookeeper/zookeeper.service.erb'),
      }

      file { 'zookeeper-old-initscript':
        path   => '/etc/init.d/zookeeper',
        ensure => absent,
      }

      service { 'zookeeper-service':
        name   => 'zookeeper',
        ensure => 'running',
        enable => true,
      }

      Class['zookeeper'] ->
      File['/lib/systemd/system/zookeeper.service'] ->
      File['zookeeper-old-initscript'] ->
      Service['zookeeper-service']

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
      contain 'zookeeper'
    }
    else {
      fail("Unsupported Operating System Family ${::osfamily}")
    }
  }
