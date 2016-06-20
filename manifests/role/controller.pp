# == Class: midonet_openstack::profile::role::controller
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
class midonet_openstack::role::controller {

  # ****************************************************************************
  # Old Puppet modules, exposed here as reference
  # ****************************************************************************

  #class { '::openstack::profile::firewall': }
  #class { '::openstack::profile::rabbitmq': } ->
  #class { '::openstack::profile::mysql': } ->
  #class { '::openstack::profile::keystone': } ->
  #class { '::midonet_openstack::profile::neutron::server':} ->
  #class { '::midonet_openstack::profile::neutron::router':} ->
  #class { '::openstack::profile::glance::api': } ->
  #class { '::openstack::profile::glance::auth': } ->
  #class { '::openstack::profile::cinder::api': } ->
  #class { '::openstack::profile::cinder::volume': } ->
  #class { '::openstack::profile::nova::api': } ->
  #class { '::openstack::profile::horizon': }
  #class { '::openstack::profile::auth_file': }
  #class { '::midonet_openstack::setup::sharednetwork': }
  #class { '::openstack::setup::cirros': }
  #Class['::midonet_openstack::setup::sharednetwork'] ->
  #  Class['::midonet_openstack::profile::neutron::server']
  #Class['::midonet_openstack::setup::sharednetwork'] ->
  #  Class['::apache::service']


  # ****************************************************************************
  # New stuff
  # ****************************************************************************

  include ::openstack_integration
  include ::openstack_integration::rabbitmq
  include ::openstack_integration::mysql
  include ::openstack_integration::keystone
  include ::openstack_integration::repos

  # Create necessary users in RabbitMQ and grant them permissions
  rabbitmq_user { ['neutron', 'nova', 'glance']:
    admin    => true,
    password => 'an_even_bigger_secret',
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { ['neutron@/', 'nova@/', 'glance@/']:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }

}
