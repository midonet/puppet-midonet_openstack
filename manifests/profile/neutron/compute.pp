# The midonet_openstack::profile::neutron::compute
# configures neutron in compute node
#
# Suitable for both Vanilla and Midonet OpenStack installations

class midonet_openstack::profile::neutron::compute {
  include ::openstack_integration::config

  $controller_management_address = $::midonet_openstack::params::controller_address_management
  $controller_api_address        = $::midonet_openstack::params::controller_address_api

  nova_config {
    'neutron/auth_url':                   value => "http://${controller_api_address}:5000";
    'neutron/auth_plugin':                value => 'password';
    'neutron/project_domain_id':          value => 'default';
    'neutron/user_domain_id':             value => 'default';
    'neutron/region_name':                value => $::midonet_openstack::params::region;
    'neutron/project_name':               value => 'admin';
    'neutron/username':                   value => 'neutron';
    'neutron/password':                   value => $::midonet_openstack::params::neutron_password;
  }
}