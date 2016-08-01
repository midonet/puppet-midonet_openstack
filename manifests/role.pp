# == Class: midonet_openstack::role
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
class midonet_openstack::role inherits midonet_openstack::params{
  include ::midonet_openstack::profile::base
  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '14.10') > 0 {
    # Xenial with Mitaka is not supported officialy so lets try to workaround it
    # This is seriously a pity..
    notice('Xenial detected')
    Service<| title == 'libvirt'  |> { provider => 'systemd' }
    Service<| title == 'mysqld'   |> { provider => 'systemd' }
    Service<| title == 'keystone' |> { provider => 'systemd' }

  }
}
