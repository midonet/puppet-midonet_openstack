# == Class: midonet_openstack::role::allinone_analytics
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
# [*controller_ip*]
#   Controller node ip address
class midonet_openstack::role::allinone_analytics (
  $mem_username,
  $mem_password,
  $client_ip               = $::midonet_openstack::params::controller_address_management,
  $controller_ip           = $::midonet_openstack::params::controller_address_api,
  $is_mem                  = undef,
  $manage_repo             = undef,
  ) inherits ::midonet_openstack::role {
  # class { '::midonet_openstack::profile::firewall::firewall': }
  # contain '::midonet_openstack::profile::firewall::firewall'
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
  class { '::midonet_openstack::profile::midojava::midojava':
    version => 7
  }
  contain '::midonet_openstack::profile::midojava::midojava'

  include ::midonet::params

  class { '::midonet::analytics':
    zookeeper_hosts => [{
      'ip' => $controller_ip}
      ],
    is_mem          => $is_mem,
    mem_username    => $mem_username,
    mem_password    => $mem_password
  }

  # Class['midonet_openstack::profile::firewall::firewall']         ->
  Class['midonet_openstack::profile::repos']                      ->
  Class['midonet::repository']                                    ->
  Class['midonet_openstack::profile::midojava::midojava']         ->
  Class['midonet::analytics']
}
