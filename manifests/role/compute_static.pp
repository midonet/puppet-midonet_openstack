# == Class: midonet_openstack::role::allinone
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
#  [*rabbitmq_hosts*]
#    Rabbitmq hosts
# [*is_mem*]
#   Using MEM installation?
# [*mem_username*]
#   Midonet MEM username
# [*mem_password*]
#   Midonet MEM password
class midonet_openstack::role::compute_static (
  $rabbitmq_hosts,
  $is_mem                  = false,
  $mem_username            = undef,
  $mem_password            = undef,
  ) inherits ::midonet_openstack::role {

  include stdlib
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

  if $::osfamily == 'RedHat' {
    package { 'openstack-selinux':
    ensure => 'latest',
  }

  class { '::midonet_openstack::profile::midojava::midojava':}
  contain '::midonet_openstack::profile::midojava::midojava'

  class { '::midonet_openstack::profile::neutron::compute': }
  contain '::midonet_openstack::profile::neutron::compute'

  class { '::midonet_openstack::profile::nova::compute': }
  contain '::midonet_openstack::profile::nova::compute'

  include ::midonet::params
  # Add midonet-cluster


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

  # Add midonet-agent
  class { 'midonet::agent':
    controller_host => $::midonet_openstack::params::controller_address_management,
    metadata_port   => '8775',
    shared_secret   => $::midonet_openstack::params::neutron_shared_secret,
    zookeeper_hosts => [{
        'ip' => $::midonet_openstack::params::controller_address_management}
        ],
    require         => Anchor['::java::end']
  }
  contain '::midonet::agent'

  ##midonet_openstack#::resources::firewall { 'Midonet API': port => '8181', }
  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => "http://${::midonet_openstack::params::controller_address_management}:8181",
    username        => 'midogod',
    password        => 'midogod',
    tenant_name     => 'midokura',
  }

  midonet::resources::network_creation { 'Test Edge Router Setup':
    api_endpoint            => "http://${::midonet_openstack::params::controller_address_management}:8181/midonet-api",
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
    nic            => 'enp0s3',
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
  Class['midonet_openstack::profile::nova::compute']              ->
  Class['midonet_openstack::profile::neutron::compute']           ->
  Class['midonet::agent']                                         ->
  Midonet_host_registry[$::fqdn]                                  ->
  Midonet::Resources::Network_creation['Test Edge Router Setup']  ->
  Class['midonet::gateway::static']

}
