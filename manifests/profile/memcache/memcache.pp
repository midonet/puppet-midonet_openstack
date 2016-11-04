# The profile to install a local instance of memcache

# == Parameters
#
#  [*port*]
#    Port where memcache listens
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
class midonet_openstack::profile::memcache::memcache($port = '11211') {

  ##midonet_openstack#::resources::firewall { 'Memcache': port => $port, }

  class { '::memcached':
    listen_ip => $::midonet_openstack::params::controller_address_management, #'127.0.0.1',
    tcp_port  => $port,
    udp_port  => $port,
  }
}
