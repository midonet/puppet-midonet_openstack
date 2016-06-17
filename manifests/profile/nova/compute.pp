# == Class: midonet_openstack::profile::nova::compute
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
class midonet_openstack::profile::nova::compute {
    class {'openstack::profile::nova::compute': }

    class { '::nova':
      database_connection     => 'mysql+pymysql://nova:nova@127.0.0.1/nova?charset=utf8',
      api_database_connection => 'mysql+pymysql://nova_api:nova@127.0.0.1/nova_api?charset=utf8',
      rabbit_hosts            => $::openstack::rabbitmq::hosts,
      rabbit_userid           => $::openstack::rabbitmq::user,
      rabbit_password         => 'an_even_bigger_secret',
      glance_api_servers      => join($::openstack::config::glance_api_servers, ','),
      memcached_servers   => ["$::openstack::config::controller_address_management:11211"],
      verbose                 => $::openstack::config::verbose,
      debug                   => $::openstack::config::debug,
    }

    class { '::nova::network::neutron':
      neutron_admin_password => $::openstack::config::neutron_password,
      neutron_region_name    => $::openstack::config::region,
      neutron_admin_auth_url => "http://${controller_management_address}:35357/v2.0",
      neutron_url            => "http://${controller_management_address}:9696",
      vif_plugging_is_fatal  => false,
      vif_plugging_timeout   => '0',
    }

    exec { "add_midonet_rootwrap":
        command => "/bin/echo -e '[Filters]\nmm-ctl: CommandFilter, mm-ctl, root' > /etc/nova/rootwrap.d/midonet.filters",
        require => Class['openstack::common::nova']
    }
}
