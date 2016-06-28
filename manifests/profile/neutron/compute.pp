# The midonet_openstack::profile::neutron::compute
# configures neutron in compute node
#
# Suitable for both Vanilla and Midonet OpenStack installations

class midonet_openstack::profile::neutron::compute {
  include ::openstack_integration::config

  nova_config {
    'neutron/project_domain_id': value => 'default';
    'neutron/user_domain_id': value => 'default';
  }
}
