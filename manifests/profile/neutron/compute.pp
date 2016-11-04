# == Class: midonet_openstack::profile::neutron::compute
# The midonet_openstack::profile::neutron::compute
# configures neutron in compute node
#
# Suitable for both Vanilla and Midonet OpenStack installations
# == Parameters
#
#  [*controller_management_address*]
#    Management IP of controller host
#
#  [*controller_api_address*]
#    API IP of controller host
#
#  [*region_name*]
#    Openstack region name for nova
#
#  [*neutron_password*]
#    Password for neutron user
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
class midonet_openstack::profile::neutron::compute (
  $controller_management_address = $::midonet_openstack::params::controller_address_management,
  $controller_api_address        = $::midonet_openstack::params::controller_address_api,
  $region_name                   = $::midonet_openstack::params::region,
  $neutron_password              = $::midonet_openstack::params::neutron_password
  ){
  include ::openstack_integration::config

  nova_config {
    'neutron/auth_url':                   value => "http://${controller_api_address}:5000";
    'neutron/auth_plugin':                value => 'password';
    'neutron/project_domain_id':          value => 'default';
    'neutron/user_domain_id':             value => 'default';
    'neutron/region_name':                value => $region_name;
    'neutron/project_name':               value => 'admin';
    'neutron/username':                   value => 'neutron';
    'neutron/password':                   value => $neutron_password;
  }
}
