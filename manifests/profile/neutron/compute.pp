# The midonet_openstack::profile::neutron::compute
# configures neutron in compute node
#
# Suitable for both Vanilla and Midonet OpenStack installations

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
