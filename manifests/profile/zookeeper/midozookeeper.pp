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
class midonet_openstack::profile::zookeeper::midozookeeper(
  $id                   = 1,
  $client_ip            = $::ipaddress_eth0,
  $zk_servers           = zookeeper_servers($midonet_openstack::params::zookeeper_servers),
  $cfg_dir              = '/etc/zookeeper'
  ){

    midonet_openstack::resources::firewall { 'Zookeeper': port => '2181'}
    if $::osfamily == 'RedHat'
    {
      $zk_packages = ['zookeeper']

      class {'::zookeeper':
        servers             => $zk_servers,
        id                  => $id,
        cfg_dir             => $cfg_dir,
        client_ip           => $client_ip,
        packages            => $zk_packages,
        service_name        => 'zookeeper',
        manage_service      => false,
        manage_service_file => false,
        require             => Class['midonet::repository']
      }
      contain '::zookeeper'

      file { 'zk service file':
        ensure  => file,
        path    => '/lib/systemd/system/zookeeper.service',
        content => template('midonet_openstack/zookeeper/zookeeper.service.erb'),
      }

      file { 'zookeeper-old-initscript':
        ensure => absent,
        path   => '/etc/init.d/zookeeper',
      }

      service { 'zookeeper-service':
        ensure    => 'running',
        name      => 'zookeeper',
        enable    => true,
        require   => [File['zk service file','zookeeper-old-initscript',"${cfg_dir}/zoo.cfg"],
                      Class['zookeeper']],
        subscribe => [
                      File["${cfg_dir}/myid"], File["${cfg_dir}/zoo.cfg"],
                      File["${cfg_dir}/environment"], File["${cfg_dir}/log4j.properties"],
                      ]
      }

      Class['zookeeper'] ->
      File['zk service file'] ->
      File['zookeeper-old-initscript'] ->
      Service['zookeeper-service']

    }
    elsif $::osfamily == 'Debian'
    {
      $zk_packages = ['zookeeper','zookeeperd']

      class {'::zookeeper':
        servers      => $zk_servers,
        id           => $id,
        cfg_dir      => $cfg_dir,
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
