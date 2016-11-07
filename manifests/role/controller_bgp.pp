# == Class: midonet_openstack::role::controller_bgp
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
# [*zk_id*]
#   ID of this Zookeeper node on the cluster
#
# [*client_ip*]
#   Management IP for the controller node
#
# [*cassandra_seeds*]
#   Cassandra seeds that form the cluster
#
# [*cassandra_rep_factor*]
#   Replication factor for the Cassandra cluster
#
# [*zk_servers*]
#   Other ZK servers that might be in the cluster
#
# [*is_mem*]
#   Is this a MEM installation?
#
# [*mem_username*]
#   Username for the MEM repository
#
# [*mem_password*]
#   Password for the MEM repository
#
# [*mem_apache_servername*]
#   Servername that will be set in the MEM vhost
#
# [*metadata_port*]
#   Neutron metadata port
#
# [*shared_secret*]
#   Neutron shared secret
#
# [*horizon_extra_aliases*]
#   Set it in case the controller node has different hostnames pointing to it
#
# [*cluster_ip*]
#   IP pointing to the MidoNet cluster
#
# [*analytics_ip*]
#   IP pointing to the MidoNet analytics node
#
# [*admin_user*]
#   Default value is 'admin'
#
# [*admin_password*]
#   Password for the admin user
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
# [*gw_bgp_local_asn_number*]
#   Local AS number
#
# [*gw_bgp_advertised_networks*]
#   Network that is going to be advertised (FIP network)
#
# [*gw_bgp_neighbors_ips*]
#   BGP neighbors IPs
#
# [*gw_bgp_neighbors_asns*]
#   BGP neighbors AS numbers
#
# [*gw_bgp_neighbors_nets*]
#   BGP neighbors networks
#
#
class midonet_openstack::role::controller_bgp (
  $zk_id,
  $client_ip                   = $::midonet_openstack::params::controller_address_management,
  $cassandra_seeds             = $::midonet_openstack::params::cassandra_seeds,
  $cassandra_rep_factor        = '1',
  $zk_servers                  = $::midonet_openstack::params::zookeeper_servers,
  $is_mem                      = false,
  $mem_username                = undef,
  $mem_password                = undef,
  $mem_apache_servername       = $::ipaddress,
  $metadata_port               = '8775',
  $shared_secret               = $::midonet_openstack::params::neutron_shared_secret,
  $horizon_extra_aliases       = undef,
  $cluster_ip                  = undef,
  $analytics_ip                = undef
  $admin_user                  = 'admin',
  $admin_password              = $::midonet_openstack::params::keystone_admin_password,
  $midonet_username            = 'midogod',
  $midonet_password            = 'midogod',
  $midonet_tenant_name         = 'midokura',
  $nc_edge_router_name         = 'edge-router',
  $nc_edge_network_name        = 'net-edge1-gw1',
  $nc_edge_subnet_name         = 'subnet-edge1-gw1',
  $nc_edge_cidr                = '172.19.0.0/30',
  $nc_port_name                = 'testport',
  $nc_port_fixed_ip            = '172.19.0.2',
  $nc_port_interface_name      = 'enp0s3',
  $nc_gateway_ip               = '172.172.0.1',
  $nc_allocation_pools         = ['start=172.172.0.100,end=172.172.0.200'],
  $nc_subnet_cidr              = '172.172.0.0/24',
  $gw_bgp_local_asn_number     = '12345',
  $gw_bgp_advertised_networks  = ['172.172.0.0/24'],
  $gw_bgp_neighbors_ips        = ['10.88.88.5'],
  $gw_bgp_neighbors_asns       = ['65535'],
  $gw_bgp_neighbors_nets       = ['10.88.88.0/29']
) inherits ::midonet_openstack::role {

  # Variables that can't be set up by the parameters
  $controller_address_management = $::midonet_openstack::params::controller_address_management

  include stdlib
  include ::midonet::params

  if $::osfamily == 'RedHat' {
    package { 'openstack-selinux':
      ensure => 'latest',
    }

    $zk_requires=[
      Service['zookeeper-service'],
      File['/etc/zookeeper/conf/zoo.cfg']
    ]
  }
  if $::osfamily == 'Debian' {
    if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0 {
      File_line<| match == 'libvirtd_opts='  |> { line => 'libvirtd_opts="-l"' }
    }

    $zk_requires=[
      Package['zookeeper','zookeeperd'],
      File['/etc/zookeeper/conf/zoo.cfg']
    ]
  }

  package { 'bridge-utils':
    ensure => installed,
    before => [Midonet_host_registry[$::fqdn],
    Midonet::Resources::Network_creation['Test Edge Router Setup']]
  }

  # Add main OpenStack repositories
  class { '::midonet_openstack::profile::repos': }
  contain '::midonet_openstack::profile::repos'

  # Add MidoNet repositories
  class { '::midonet::repository':
    is_mem       => $is_mem,
    mem_username => $mem_username,
    mem_password => $mem_password
  }
  contain '::midonet::repository'

  # Install OpenJDK 8
  class { '::midonet_openstack::profile::midojava::midojava':}
  contain '::midonet_openstack::profile::midojava::midojava'

  # Install Zookeeper
  class { '::midonet_openstack::profile::zookeeper::midozookeeper':
    id         => $zk_id,
    zk_servers => zookeeper_servers($zk_servers),
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

  # Install Cassandra
  class { '::midonet_openstack::profile::cassandra::midocassandra':
    seeds        => $cassandra_seeds,
    seed_address => $client_ip,
  }
  contain '::midonet_openstack::profile::cassandra::midocassandra'

  # Core OpenStack components
  class { '::midonet_openstack::profile::memcache::memcache':}
  contain '::midonet_openstack::profile::memcache::memcache'
  class { '::midonet_openstack::profile::rabbitmq::controller': }
  contain '::midonet_openstack::profile::rabbitmq::controller'
  class { '::midonet_openstack::profile::keystone::controller':}
  contain '::midonet_openstack::profile::keystone::controller'
  class { '::midonet_openstack::profile::mysql::controller': }
  contain '::midonet_openstack::profile::mysql::controller'
  class { '::midonet_openstack::profile::glance::controller':}
  contain '::midonet_openstack::profile::glance::controller'
  class { '::midonet_openstack::profile::neutron::controller':}
  contain '::midonet_openstack::profile::neutron::controller'
  class { '::midonet_openstack::profile::nova::api':}
  contain '::midonet_openstack::profile::nova::api'
  class { '::midonet_openstack::profile::horizon::horizon':
    extra_aliases => $horizon_extra_aliases,
  }
  contain '::midonet_openstack::profile::horizon::horizon'

  # MidoNet Cluster (API)
  class { 'midonet::cluster':
    zookeeper_hosts      => [ { 'ip' => $client_ip} ],
    cassandra_servers    => [ $controller_address_management ],
    cassandra_rep_factor => $cassandra_rep_factor,
    keystone_admin_token => $midonet_openstack::params::keystone_admin_token,
    keystone_host        => $controller_address_management,
    require              => $zk_requires,
  }
  contain '::midonet::cluster'

  # MidoNet CLI
  class { 'midonet::cli':
    username => $admin_user,
    password => $admin_password,
    require  => $zk_requires
  }
  contain '::midonet::cli'

  # Add MEM manager if necessary
  if $is_mem == true {
    class { 'midonet::mem':
      mem_apache_servername => $mem_apache_servername,
      cluster_ip            => $cluster_ip,
      analytics_ip          => $analytics_ip
    }
  }

  # MidoNet Agent (a.k.a. Midolman)
  class { 'midonet::agent':
    controller_host => '127.0.0.1',
    metadata_port   => $metadata_port,
    shared_secret   => $shared_secret,
    zookeeper_hosts => [ { 'ip' => $client_ip} ],
    require         => concat(
      $zk_requires,
      Class['::midonet::cluster::install', '::midonet::cluster::run']
    )
  }
  contain '::midonet::agent'

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

  midonet_gateway_bgp { 'edge-router':
    ensure                  => present,
    bgp_local_as_number     => $gw_bgp_local_asn_number,
    bgp_advertised_networks => $gw_bgp_advertised_networks,
    bgp_neighbors           => generate_bgp_neighbors(
      $gw_bgp_neighbors_ips,
      $gw_bgp_neighbors_asns,
      $gw_bgp_neighbors_nets
    ),
    midonet_api_url         => 'http://127.0.0.1:8181',
    username                => $admin_user,
    password                => $admin_password,
    tenant_name             => $midonet_tenant_name,
    require                 => Midonet::Resources::Network_creation['Edge Router Setup'],
  }

  Class['midonet_openstack::profile::repos']                     ->
  Class['midonet::repository']                                   ->
  Class['midonet_openstack::profile::midojava::midojava']        ->
  Anchor['rabbitmq::end']                                        ->
  Class['midonet_openstack::profile::zookeeper::midozookeeper']  ->
  Class['midonet_openstack::profile::cassandra::midocassandra']  ->
  Class['midonet_openstack::profile::mysql::controller']         ->
  Class['midonet_openstack::profile::memcache::memcache']        ->
  Class['midonet_openstack::profile::keystone::controller']      ->
  Class['midonet_openstack::profile::glance::controller']        ->
  Class['midonet_openstack::profile::neutron::controller']       ->
  Class['midonet_openstack::profile::nova::api']                 ->
  Class['midonet_openstack::profile::horizon::horizon']          ->
  Class['midonet::cluster']                                      ->
  Class['midonet::agent']                                        ->
  Class['midonet::cli']                                          ->
  Midonet_host_registry[$::fqdn]                                 ->
  Midonet::Resources::Network_creation['Edge Router Setup']      ->
  Midonet_gateway_bgp['edge-router']

  Keystone_tenant<||> ->
  Keystone_role<||> ->
  Midonet_openstack::Resources::Keystone_user<||> ->
  Midonet_host_registry[$::fqdn]

}
