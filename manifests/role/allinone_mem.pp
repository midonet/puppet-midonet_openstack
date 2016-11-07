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
#  [*zookeeper_client_ip*]
#    Zookeeper Host Ip
# [*is_mem*]
#   Using MEM installation?
# [*mem_username*]
#   Midonet MEM username
# [*mem_password*]
#   Midonet MEM password
class midonet_openstack::role::allinone_mem (
  $mem_username,
  $mem_password,
  $client_ip               = $::midonet_openstack::params::controller_address_management,
  $is_mem                  = true,
  $manage_repo             = true,
  $mem_apache_servername   = $::ipaddress,
  $horizon_extra_aliases   = undef,
  $cluster_ip              = undef,
  $analytics_ip            = undef,
  $is_insights             = undef,
  $is_ssl                  = undef,
  $insights_ssl            = undef
  ) inherits ::midonet_openstack::role {

  include ::stdlib
  #class { '::midonet_openstack::profile::firewall::firewall': }
  #contain '::midonet_openstack::profile::firewall::firewall'
  class { '::midonet_openstack::profile::repos': }
  contain '::midonet_openstack::profile::repos'
  class { '::midonet::repository':
    is_mem            => $is_mem,
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
    zk_servers => zookeeper_servers($midonet_openstack::params::zookeeper_servers),
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
    seeds              => $::midonet_openstack::params::cassandra_seeds,
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
      is_mem               => $is_mem,
      zookeeper_hosts      => [{
        'ip' => $client_ip}
        ],
      cassandra_servers    => ['127.0.0.1'],
      cassandra_rep_factor => '1',
      keystone_admin_token => 'testmido',
      keystone_host        => $::midonet_openstack::params::controller_address_management,
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
    shared_secret   => $::midonet_openstack::params::neutron_shared_secret,
    zookeeper_hosts => [{
      'ip' => $client_ip}
      ],
    is_mem          => $is_mem,
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
      Midonet::Resources::Network_creation['Test Edge Router Setup']]
    }
  }

  ##midonet_openstack#::resources::firewall { 'Midonet API': port => '8181', }
  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => 'http://127.0.0.1:8181',
    username        => 'midogod',
    password        => 'midogod',
    tenant_name     => 'midokura',
  }

  midonet::resources::network_creation { 'Test Edge Router Setup':
    api_endpoint            => 'http://127.0.0.1:8181/midonet-api',
    keystone_username       => 'midogod',
    keystone_password       => 'midogod',
    tenant_name             => 'midokura',
    controller_ip           => '127.0.0.1',
    controller_neutron_port => '9696',
    edge_router_name        => 'edge-router',
    edge_network_name       => 'net-edge1-gw1',
    edge_subnet_name        => 'subnet-edge1-gw1',
    edge_cidr               => '172.19.0.0/30',
    port_name               => 'testport',
    port_fixed_ip           => '172.19.0.2',
    port_interface_name     => 'veth1',
    gateway_ip              => '172.172.0.1',
    allocation_pools        => ['start=172.172.0.100,end=172.172.0.200'],
    subnet_cidr             => '172.172.0.0/24',
  }

  class { 'midonet::gateway::static':
    nic            => 'eth0',
    fip            => '172.172.0.0/24',
    edge_router    => 'edge-router',
    veth0_ip       => '172.19.0.1',
    veth1_ip       => '172.19.0.2',
    veth_network   => '172.19.0.0/30',
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
  Midonet::Resources::Network_creation['Test Edge Router Setup']  ->
  Class['midonet::gateway::static']

  Keystone_tenant<||>
  -> Keystone_role<||>
  -> Midonet_openstack::Resources::Keystone_user<||>
  -> Midonet_host_registry[$::fqdn]

  if $is_mem {

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
}