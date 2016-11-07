# == Class: midonet_openstack::role::compute_bgp
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
# [*client_ip*]
#   Zookeeper Host Ip
#
# [*is_mem*]
#   Using MEM installation?
#
# [*mem_username*]
#   Username for the MEM repository
#
# [*mem_password*]
#   Password for the MEM repository
#
# [*metadata_port*]
#   Default value is '8775'
#
# [* $shared_secret*]
#   Neutron shared secret
#
# [* $midonet_username*]
#   Privileged user to be used with MidoNet
#
# [* $midonet_password*]
#   Password for this user
#
# [* $midonet_tenant_name*]
#   Tenant which this user uses
#
class midonet_openstack::role::compute_bgp (
  $client_ip               = $::midonet_openstack::params::controller_address_management,
  $is_mem                  = false,
  $mem_username            = undef,
  $mem_password            = undef,
  $metadata_port           = '8775',
  $shared_secret           = $::midonet_openstack::params::neutron_shared_secret,
  $midonet_username        = 'midogod',
  $midonet_password        = 'midogod',
  $midonet_tenant_name     = 'midokura',
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
      File['/etc/zookeeper/zoo.cfg']
    ]

    # Temporary hack to make sure RabbitMQ does not steal UID
    # of Keystone
    Package<| title == 'keystone' |> -> Package<| title == 'rabbitmq-server' |>
  }
  if $::osfamily == 'Debian' {
    $zk_requires=[
      Package['zookeeper','zookeeperd'],
      File['/etc/zookeeper/zoo.cfg']
    ]

    # Xenial doesnt like daemons..
    if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0 {
      File_line<| match == 'libvirtd_opts=' |> { line => 'libvirtd_opts="-l"' }
    }
  }

  # Need this package to translate from new interface names to old ones
  package { 'bridge-utils':
    ensure => installed,
    before => Midonet_host_registry[$::fqdn]
  }

  class { '::midonet_openstack::profile::repos': }
  contain '::midonet_openstack::profile::repos'

  class { '::midonet::repository':
    is_mem       => $is_mem,
    mem_username => $mem_username,
    mem_password => $mem_password
  }
  contain '::midonet::repository'

  class { '::midonet_openstack::profile::midojava::midojava': }
  contain '::midonet_openstack::profile::midojava::midojava'

  class { '::midonet_openstack::profile::nova::compute': }
  contain '::midonet_openstack::profile::nova::compute'


  # Add midonet-agent
  class { 'midonet::agent':
    controller_host => $controller_address_management,
    metadata_port   => $metadata_port,
    shared_secret   => $shared_secret,
    zookeeper_hosts => [ { 'ip' => $client_ip } ],
  }
  contain '::midonet::agent'

  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => "http://${controller_address_management}:8181",
    username        => $midonet_username,
    password        => $midonet_password,
    tenant_name     => $midonet_tenant_name,
  }

  Class['midonet_openstack::profile::repos']              ->
  Class['midonet::repository']                            ->
  Class['midonet_openstack::profile::midojava::midojava'] ->
  Class['midonet_openstack::profile::nova::compute']      ->
  Class['midonet::agent']                                 ->
  Midonet_host_registry[$::fqdn]

}
