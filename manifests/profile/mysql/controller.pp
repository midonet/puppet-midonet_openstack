# == Class: midonet_openstack::profile::mysql::controller
#
#  Configure MySQL on a controller node
# == Parameters
#
#  [*bind_address*]
#    Where should mysql listen at
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
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
class midonet_openstack::profile::mysql::controller (
  $bind_address = $::midonet_openstack::params::controller_address_management
  ){
  class { '::mysql::server':
    override_options => {
      mysqld => { bind-address      => $bind_address} #Allow remote connections
    },
    # ... other class options
  }
}
