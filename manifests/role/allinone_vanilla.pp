# == Class: midonet_openstack::role::allinone_vanilla
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
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
class midonet_openstack::role::allinone_vanilla (
  $client_ip = $::midonet_openstack::params::controller_address_management
  ) inherits ::midonet_openstack::role {
  class { '::midonet_openstack::profile::firewall::firewall': } ->
  class { '::midonet_openstack::profile::repos': } ->
  class { '::midonet::repository': }

  if $::osfamily == 'RedHat' {
    package { 'openstack-selinux':
    ensure => 'latest'
  }
  # temporary hack to make sure RabbitMQ does not steal UID
  # of Keystone
  Package<| title == 'keystone' |> -> Package<| title == 'rabbitmq-server' |>
  }
  class { '::midonet_openstack::profile::memcache::memcache':}
  class { '::midonet_openstack::profile::keystone::controller': }
  class { '::midonet_openstack::profile::mysql::controller': }
  class { '::midonet_openstack::profile::rabbitmq::controller': }
  class { '::midonet_openstack::profile::glance::controller':
    require => Class['::midonet_openstack::profile::keystone::controller'],
  }
  class { '::midonet_openstack::profile::neutron::controller_vanilla': }
  class { '::midonet_openstack::profile::nova::api':}
  class { '::midonet_openstack::profile::nova::compute_vanilla': }
  class { '::midonet_openstack::profile::horizon::horizon':}
}
