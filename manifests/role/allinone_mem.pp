# == Class: midonet_openstack::role::allinone_mem
#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# == Parameters
#
# [*mem_username*]
#   MEM_username
#
# [*mem_password*]
#   MEM Password
#
# [*client_ip*]
#   Self ip on the management network
#
# [*manage_repo*]
#   Manage midonet repositories
#
# [*mem_apache_servername*]
#   MEM apache servername
#
# [*horizon_extra_aliases*]
#  List of extra aliases for horizon vhost
#
# [*cluster_ip*]
#   IP where the cluster is running
#
# [*analytics_ip*]
#   Analytics IP
#
# [*is_insights*]
#   Using MEM insights?
#
# [*is_ssl*]
#   Is MEM using SSL?
#
# [*insights_ssl*]
#  Is MEM insights using SSL?
#
# [*zookeeper_servers*]
#  List of zookeeper servers
#
# [*cassandra_seeds*]
#  List of cassandra servers
#
# [*controller_address_management*]
#  Management IP of the controller node
#
# [*neutron_shared_secret*]
#  Shared secret for neutron
#
#
# [*admin_user*]
#   Keystone admin username
#
# [*admin_password*]
#   Keystone admin password
#
# [*midonet_username*]
#   A user with admin privileges to be used with MidoNet
#
# [*midonet_password*]
#   Password for this user
#
# [*midonet_tenant_name*]
#   Tenant which this user uses
#
# [*nc_edge_router_name*]
#   Name that will be assigned to the edge router
#
# [*nc_edge_network_name*]
#   Name of the external network of the edge router
#
# [*nc_edge_subnet_name*]
#   Name of the subnet on that network
#
# [*nc_edge_cidr*]
#   Network on which the physical port that is bound to the edge router is
#
# [*nc_port_name*]
#   Name of the Neutron binding port
#
# [*nc_port_fixed_ip*]
#   IP assigned on that port
#
# [*nc_port_interface_name*]
#   Physical interface bound to the edge router
#
# [*nc_gateway_ip*]
#   IP on the FIP range that will be assigned to the gateway
#
# [*nc_allocation_pools*]
#   Start/end range used in the FIP network
#
# [*nc_subnet_cidr*]
#   CIDR for the FIP network
#
# [*gw_nic*]
#   Gateway NIC interface
#
# [*gw_fip*]
#   Gateway FIP Network
#
# [*gw_edge_router*]
#   Name of the edge router
#
# [*gw_veth0_ip*]
#   Veth0 ip
#
# [*gw_veth1_ip*]
#   Veth1 ip
#
# [*gw_veth_network*]
#   CIDR of the VETH network
#

class midonet_openstack::role::allinone_mem (
  $mem_username,
  $mem_password,
  $client_ip                     = $::midonet_openstack::params::controller_address_management,
  $manage_repo                   = true,
  $mem_apache_servername         = $::ipaddress,
  $horizon_extra_aliases         = undef,
  $cluster_ip                    = undef,
  $analytics_ip                  = undef,
  $is_insights                   = undef,
  $is_ssl                        = undef,
  $insights_ssl                  = undef,
  $zookeeper_servers             = $midonet_openstack::params::zookeeper_servers,
  $cassandra_seeds               = $::midonet_openstack::params::cassandra_seeds,
  $controller_address_management = $::midonet_openstack::params::controller_address_management,
  $neutron_shared_secret         = $::midonet_openstack::params::neutron_shared_secret,
  $midonet_username              = 'midogod',
  $midonet_password              = 'midogod',
  $midonet_tenant_name           = 'midokura',
  $nc_edge_router_name           = 'edge-router',
  $nc_edge_network_name          = 'net-edge1-gw1',
  $nc_edge_subnet_name           = 'subnet-edge1-gw1',
  $nc_edge_cidr                  = '172.19.0.0/30',
  $nc_port_name                  = 'testport',
  $nc_port_fixed_ip              = '172.19.0.2',
  $nc_port_interface_name        = 'veth1',
  $nc_gateway_ip                 = '172.172.0.1',
  $nc_allocation_pools           = ['start=172.172.0.100,end=172.172.0.200'],
  $nc_subnet_cidr                = '172.172.0.0/24',
  $gw_nic                        = 'eth0',
  $gw_fip                        = '172.172.0.0/24',
  $gw_edge_router                = 'edge-router',
  $gw_veth0_ip                   = '172.19.0.1',
  $gw_veth1_ip                   = '172.19.0.2',
  $gw_veth_network               = '172.19.0.0/30',
  ) inherits ::midonet_openstack::role {

  include ::stdlib
  #class { '::midonet_openstack::profile::firewall::firewall': }
  #contain '::midonet_openstack::profile::firewall::firewall'
  class { '::midonet_openstack::profile::repos': }
  contain '::midonet_openstack::profile::repos'
  class { '::midonet::repository':
    is_mem            => true,
    midonet_version   => undef,
    midonet_stage     => undef,
    openstack_release => undef,
    mem_version       => undef,
    mem_username      => $mem_username,
    mem_password      => $mem_password
  }
  contain '::midonet::repository'
  class { '::midonet_openstack::profile::midojava::midojava':}
  contain '::midonet_openstack::profile::midojava::midojava'
  class { '::midonet_openstack::profile::zookeeper::midozookeeper':
    zk_servers => zookeeper_servers($zookeeper_servers),
    id         => 1,
    client_ip  => $client_ip,
    before     => Class[
      'midonet::cluster::install',
      'midonet::cluster::run',
      'midonet::agent::install',
      'midonet::agent::run',
      'midonet::cli',
    ],
  }
  contain '::midonet_openstack::profile::zookeeper::midozookeeper'

  class {'::midonet_openstack::profile::cassandra::midocassandra':
    seeds              => $cassandra_seeds,
    seed_address       => $client_ip,
    storage_port       => '7000',
    ssl_storage_port   => '7001',
    client_port        => '9042',
    client_port_thrift => '9160',
  }
  contain '::midonet_openstack::profile::cassandra::midocassandra'
  if $::osfamily == 'RedHat' {
    package { 'openstack-selinux':
    ensure => 'latest',
  }

  $zk_requires=[
    Service['zookeeper-service'],
    File['/etc/zookeeper/conf/zoo.cfg']
  ]


  }
  if $::osfamily == 'Debian'
  {
    $zk_requires=[
      Package['zookeeper','zookeeperd'],
      File['/etc/zookeeper/conf/zoo.cfg']
    ]
  }
  class { '::midonet_openstack::profile::memcache::memcache':}
  contain '::midonet_openstack::profile::memcache::memcache'
  class { '::midonet_openstack::profile::keystone::controller': }
  contain '::midonet_openstack::profile::keystone::controller'
  class { '::midonet_openstack::profile::mysql::controller': }
  contain '::midonet_openstack::profile::mysql::controller'
  class { '::midonet_openstack::profile::rabbitmq::controller': }
  contain '::midonet_openstack::profile::rabbitmq::controller'
  class { '::midonet_openstack::profile::glance::controller':  }
  contain '::midonet_openstack::profile::glance::controller'
  class { '::midonet_openstack::profile::neutron::controller': }
  contain '::midonet_openstack::profile::neutron::controller'

  class { '::midonet_openstack::profile::nova::api': }
  contain '::midonet_openstack::profile::nova::api'
  class { '::midonet_openstack::profile::nova::compute':}
  contain '::midonet_openstack::profile::nova::compute'
  class { '::midonet_openstack::profile::horizon::horizon':
    extra_aliases => $horizon_extra_aliases
  }
  contain '::midonet_openstack::profile::horizon::horizon'
  include ::midonet::params
  # Add midonet-cluster
  class {'midonet::cluster':
      is_mem               => true,
      zookeeper_hosts      => $zookeeper_servers,
      cassandra_servers    => $cassandra_seeds,
      cassandra_rep_factor => '1',
      keystone_admin_token => 'testmido',
      keystone_host        => $controller_address_management,
      is_insights          => $is_insights,
      insights_ssl         => $insights_ssl,
      analytics_ip         => $analytics_ip,
      require              => $zk_requires
  }
  contain '::midonet::cluster'
  # Add midonet-agent
  class { 'midonet::agent':
    controller_host => '127.0.0.1',
    metadata_port   => '8775',
    shared_secret   => $neutron_shared_secret,
    zookeeper_hosts => $zookeeper_servers,
    is_mem          => true,
    manage_repo     => $manage_repo,
    mem_username    => $mem_username,
    mem_password    => $mem_password,
    require         => $zk_requires
  }
  contain '::midonet::agent'
  # Add midonet-cli
  class {'midonet::cli':
    username => 'admin',
    password => 'testmido',
    require  => $zk_requires
  }
  contain '::midonet::cli'

  #Add MEM manager class
  class {'midonet::mem':
    mem_apache_servername => $mem_apache_servername,
    cluster_ip            => $cluster_ip,
    analytics_ip          => $analytics_ip,
    is_insights           => $is_insights,
    is_ssl                => $is_ssl,
    insights_ssl          => $insights_ssl
  }

  #Xenial doesnt like daemons..
  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0
  {
    File_line<| match == 'libvirtd_opts='  |> { line => 'libvirtd_opts="-l"' }
  }

  #install bridge-utils
  if $::operatingsystem == 'Ubuntu'
  {
    package {'bridge-utils':
      ensure => installed,
      before => [Midonet_host_registry[$::fqdn],
      Midonet::Resources::Network_creation['Edge Router Setup']]
    }
  }

  ##midonet_openstack#::resources::firewall { 'Midonet API': port => '8181', }
  # Register the host
  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => "http://${controller_address_management}:8181",
    username        => $midonet_username,
    password        => $midonet_password,
    tenant_name     => $midonet_tenant_name,
    require         => Anchor['keystone::service::end']
  }

  midonet::resources::network_creation { 'Edge Router Setup':
    tenant_name         => $midonet_tenant_name,
    edge_router_name    => $nc_edge_router_name,
    edge_network_name   => $nc_edge_network_name,
    edge_subnet_name    => $nc_edge_subnet_name,
    edge_cidr           => $nc_edge_cidr,
    port_name           => $nc_port_name,
    port_fixed_ip       => $nc_port_fixed_ip,
    port_interface_name => $nc_port_interface_name,
    gateway_ip          => $nc_gateway_ip,
    allocation_pools    => $nc_allocation_pools,
    subnet_cidr         => $nc_subnet_cidr,
  }

  class { 'midonet::gateway::static':
    nic            => $gw_nic,
    fip            => $gw_fip,
    edge_router    => $gw_edge_router,
    veth0_ip       => $gw_veth0_ip,
    veth1_ip       => $gw_veth1_ip,
    veth_network   => $gw_veth_network,
    scripts_dir    => '/tmp',
    uplink_script  => 'create_fake_uplink_l2.sh',
    ensure_scripts => 'present',
  }
  contain midonet::gateway::static

  Class['midonet_openstack::profile::repos']                      ->
  Class['midonet::repository']                                    ->
  Class['midonet_openstack::profile::midojava::midojava']         ->
  Anchor['rabbitmq::end']                                         ->
  Class['midonet_openstack::profile::zookeeper::midozookeeper' ]  ->
  Class['midonet_openstack::profile::cassandra::midocassandra' ]  ->
  Class['midonet_openstack::profile::mysql::controller' ]         ->
  Class['midonet_openstack::profile::memcache::memcache' ]        ->
  Class['midonet_openstack::profile::keystone::controller' ]      ->
  Class['midonet_openstack::profile::glance::controller' ]        ->
  Class['midonet_openstack::profile::neutron::controller']        ->
  Class['midonet_openstack::profile::nova::api']                  ->
  Class['midonet_openstack::profile::nova::compute']              ->
  Class['midonet_openstack::profile::horizon::horizon']           ->
  Class['midonet::cluster']                                       ->
  Class['midonet::agent']                                         ->
  Class['midonet::cli']                                           ->
  Midonet_host_registry[$::fqdn]                                  ->
  Midonet::Resources::Network_creation['Edge Router Setup']  ->
  Class['midonet::gateway::static']

  Keystone_tenant<||>
  -> Keystone_role<||>
  -> Midonet_openstack::Resources::Keystone_user<||>
  -> Midonet_host_registry[$::fqdn]


    if $::osfamily == 'Debian' {
      $command = 'cp /tmp/15-horizon_vhost.conf /etc/apache2/sites-available/15-horizon_vhost.conf && service apache2 restart'
    }
    else {
      $command= 'cp /tmp/15-horizon_vhost.conf /etc/httpd/sites-available/15-horizon_vhost.conf && service httpd restart'
    }

    file { '/tmp/15-horizon_vhost.conf':
      ensure  => present,
      require => Class['midonet_openstack::profile::horizon::horizon'],
      source  => 'puppet:///modules/midonet_openstack/15-horizon_vhost.conf',
    }

    exec {'reload apache':
      path    => ['/usr/sbin', '/usr/bin', '/bin', '/sbin'],
      require => File['/tmp/15-horizon_vhost.conf'],
      command => $command
    }
}
