# The midonet_openstack::resources::firewall grants access to a port on the
# management network
#
# == Parameters
#
#  [*port*]
#    Port to open


define midonet_openstack::resources::firewall ( $port ) {
  # The firewall module can not handle managed rules with a leading 9 properly
  if $port =~ /9[0-9]+/ {
    firewall { "8${port} - ${title}":
      proto  => 'tcp',
      state  => ['NEW','RELATED','ESTABLISHED'],
      action => 'accept',
      dport  => $port,
      sport  => $port,
      before => Firewall['8999 - Accept all management network traffic'],
    }
  } else {
    firewall { "${port} - ${title}":
      proto  => 'tcp',
      state  => ['NEW','RELATED','ESTABLISHED'],
      action => 'accept',
      sport  => $port,
      dport  => $port,
      before => Firewall['8999 - Accept all management network traffic'],
    }
  }
}