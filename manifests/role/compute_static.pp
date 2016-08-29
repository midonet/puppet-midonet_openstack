# == Class: midonet_openstack::role::compute_static
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
class midonet_openstack::role::compute_static (
  $client_ip               = $::midonet_openstack::params::controller_address_management,
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
  class { '::midonet_openstack::profile::midojava::midojava':}
  contain '::midonet_openstack::profile::midojava::midojava'


  if $::osfamily == 'RedHat' {
    package { 'openstack-selinux':
    ensure => 'latest',
  }

  $zk_requires=[
    Service['zookeeper-service'],
    File['/etc/zookeeper/zoo.cfg']
  ]

  # temporary hack to make sure RabbitMQ does not steal UID
  # of Keystone
  Package<| title == 'keystone' |> -> Package<| title == 'rabbitmq-server' |>
  }
  if $::osfamily == 'Debian'
  {
    $zk_requires=[
      Package['zookeeper','zookeeperd'],
      File['/etc/zookeeper/zoo.cfg']
    ]
  }


  class { '::midonet_openstack::profile::nova::compute': }
  contain '::midonet_openstack::profile::nova::compute'

  include ::midonet::params

  # Add midonet-agent
  class { 'midonet::agent':
    controller_host => $::midonet_openstack::params::controller_management_address,
    metadata_port   => '8775',
    shared_secret   => $::midonet_openstack::params::neutron_shared_secret,
    zookeeper_hosts => [{
        'ip' => $client_ip}
        ],
  }
  contain '::midonet::agent'

  #Xenial doesnt like daemons..
  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0
  {
    File_line<| match == 'libvirtd_opts='  |> { line => 'libvirtd_opts="-l"' }
  }

  #install bridge-utils

  package {'bridge-utils':
    ensure => installed,
    before => Midonet_host_registry[$::fqdn]
  }


  ##midonet_openstack#::resources::firewall { 'Midonet API': port => '8181', }
  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => "http://${::midonet_openstack::params::controller_address_management}:8181",
    username        => 'midogod',
    password        => 'midogod',
    tenant_name     => 'midokura',
  }


  Class['midonet_openstack::profile::repos']                      ->
  Class['midonet::repository']                                    ->
  Class['midonet_openstack::profile::midojava::midojava']         ->
  Class['midonet_openstack::profile::nova::compute']              ->
  Class['midonet::agent']                                         ->
  Midonet_host_registry[$::fqdn]

}
