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
#  [*zookeeper_client_ip*]
#    Zookeeper Host Ip
# [*is_mem*]
#   Using MEM installation?
# [*mem_username*]
#   Midonet MEM username
# [*mem_password*]
#   Midonet MEM password
class midonet_openstack::role::allinone (
  $client_ip               = $::midonet_openstack::params::controller_address_management,
  $is_mem                  = false,
  $mem_username            = undef,
  $mem_password            = undef,
  ) inherits ::midonet_openstack::role {
  class { '::midonet_openstack::profile::firewall::firewall': }
  contain '::midonet_openstack::profile::firewall::firewall'
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
    ensure => 'latest'
  }
  # temporary hack to make sure RabbitMQ does not steal UID
  # of Keystone
  Package<| title == 'keystone' |> -> Package<| title == 'rabbitmq-server' |>
  }
  class { '::midonet_openstack::profile::memcache::memcache':}
  contain '::midonet_openstack::profile::memcache::memcache'
  class { '::midonet_openstack::profile::keystone::controller': }
  contain '::midonet_openstack::profile::keystone::controller'
  class { '::midonet_openstack::profile::mysql::controller': }
  contain '::midonet_openstack::profile::mysql::controller'
  class { '::midonet_openstack::profile::rabbitmq::controller': }
  contain '::midonet_openstack::profile::rabbitmq::controller'
  class { '::midonet_openstack::profile::glance::controller':
    require => Class['::midonet_openstack::profile::keystone::controller'],
  }
  contain '::midonet_openstack::profile::glance::controller'
  class { '::midonet_openstack::profile::neutron::controller': }
  contain '::midonet_openstack::profile::neutron::controller'

  class { '::midonet_openstack::profile::nova::api': }
  contain '::midonet_openstack::profile::nova::api'
  class { '::midonet_openstack::profile::nova::compute':}
  contain '::midonet_openstack::profile::nova::compute'
  class { '::midonet_openstack::profile::horizon::horizon':}
  contain '::midonet_openstack::profile::horizon::horizon'
  include ::midonet::params
  # Add midonet-cluster
  class {'midonet::cluster':
      zookeeper_hosts      => [{
        'ip' => $client_ip}
        ],
      cassandra_servers    => ['127.0.0.1'],
      cassandra_rep_factor => '1',
      keystone_admin_token => 'testmido',
      keystone_host        => $::midonet_openstack::params::controller_address_management,
      require              => Class['::midonet_openstack::profile::cassandra::midocassandra',
                                    '::midonet_openstack::profile::zookeeper::midozookeeper']
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
    require         => Class['::midonet_openstack::profile::cassandra::midocassandra',
                             '::midonet_openstack::profile::zookeeper::midozookeeper']
  }
  contain '::midonet::agent'
  # Add midonet-cli
  class {'midonet::cli':
    require  => Class['::midonet_openstack::profile::cassandra::midocassandra',
                      '::midonet_openstack::profile::zookeeper::midozookeeper'],
    username => 'admin',
    password => 'testmido'
  }
  contain '::midonet::cli'

  #Xenial doesnt like daemons..
  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0
  {
    File_line<| match == 'libvirtd_opts='  |> { line => 'libvirtd_opts="-l"' }
  }

  midonet_openstack::resources::firewall { 'Midonet API': port => '8181', }

  # Register the host
  midonet_host_registry { $::fqdn:
    ensure          => present,
    midonet_api_url => 'http://127.0.0.1:8181',
    username        => 'midogod',
    password        => 'midogod',
    tenant_name     => 'midokura',
    require         => Class['glance::api'],
  }

  Class['midonet_openstack::profile::firewall::firewall' ]        ->
  Class['midonet_openstack::profile::repos' ]                     ->
  Class['midonet::repository' ]                                   ->
  Class['midonet_openstack::profile::midojava::midojava']         ->
  Class['midonet_openstack::profile::zookeeper::midozookeeper' ]  ->
  Class['midonet_openstack::profile::cassandra::midocassandra' ]  ->
  Class['midonet_openstack::profile::neutron::controller']        ->
  Class['midonet_openstack::profile::nova::api']                  ->
  Class['midonet_openstack::profile::nova::compute']              ->
  Class['midonet::agent']                                         ->
  Class['midonet::cluster']                                       ->
  Class['midonet::cli']                                           ->
  Midonet_host_registry[$::fqdn]

}
