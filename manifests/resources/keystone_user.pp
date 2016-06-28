define midonet_openstack::resources::keystone_user (
  $password,
  $tenant,
  $email,
  $admin   = false,
  $enabled = true,
) {
  keystone_user { $name:
    ensure   => present,
    enabled  => $enabled,
    password => $password,
    email    => $email,
  }

  if $admin == true {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['user', 'admin'],
    }
  } else {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['user'],
    }
  }
}
