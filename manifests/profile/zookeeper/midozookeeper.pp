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
  $zk_servers,
  $id                   = 1,
  $client_ip            = $::ipaddress_eth0,
  $cfg_dir              = '/etc/zookeeper/conf',
  ){

    ##midonet_openstack#::resources::firewall { 'Zookeeper': port => '2181'}
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
      }
      contain '::zookeeper'

      file { 'zk service file':
        ensure  => file,
        path    => '/lib/systemd/system/zookeeper.service',
        content => template('midonet_openstack/zookeeper/zookeeper.service.erb'),
        before  => Class['zookeeper::os::redhat', 'zookeeper::config']
      }

      #file { 'zookeeper-old-initscript':
        #ensure => absent,
        #path   => '/etc/init.d/zookeeper',
      #}

      service { 'zookeeper-service':
        ensure  => 'running',
        name    => 'zookeeper',
        enable  => true,
        require => [
          File['zk service file',"${cfg_dir}/zoo.cfg"],
        ],
      }

      File['zk service file'] ->
      Class['zookeeper::os::redhat'] ->
      Class['zookeeper::config'] ->
      #File['zookeeper-old-initscript'] ->
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
        require      => [ File['/usr/java/default'] ],
      }
      contain 'zookeeper'
    }
    else {
      fail("Unsupported Operating System Family ${::osfamily}")
    }
  }
