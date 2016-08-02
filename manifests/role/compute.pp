# == Class: midonet_openstack::role::compute
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
# [*is_mem*]
#   Using MEM installation?
# [*manage_repos*]
#   should manage repositories?
# [*mem_username*]
#   Midonet MEM username
# [*mem_password*]
#   Midonet MEM password
class midonet_openstack::role::compute (
  $is_mem                  = false,
  $manage_repo             = false,
  $mem_username            = undef,
  $mem_password            = undef,
  ) inherits ::midonet_openstack::role {
  if $manage_repos and !defined(Class['midonet::repository']){
    class { '::midonet::repository':
      is_mem            => $is_mem,
      midonet_version   => undef,
      midonet_stage     => undef,
      openstack_release => undef,
      mem_version       => undef,
      mem_username      => $mem_username,
      mem_password      => $mem_password
    }
  }
  class { '::midonet_openstack::profile::firewall::firewall': }
  class { '::midonet_openstack::profile::repos': }
  class { '::midonet_openstack::profile::neutron::compute': }
  class { '::midonet_openstack::profile::nova::compute': }
}
