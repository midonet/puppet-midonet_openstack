# post-firewall rules to reject remaining traffic
class midonet_openstack::profile::firewall::post {
  firewall { '8999 - Accept all management network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::midonet_openstack::params::network_management,
  } ->
  firewall { '9100 - Accept all vm network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::midonet_openstack::params::network_data,
  } ->
  firewall { '9999 - Reject remaining traffic':
    proto  => 'all',
    action => 'reject',
    reject => 'icmp-host-prohibited',
    source => '0.0.0.0/0',
  }
}
