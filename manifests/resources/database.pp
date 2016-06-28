# The midonet_openstack::resources::database resource create_resources
# a user in mysql databse and asigns permissions to its db
#
# == Parameters
#
#  [*user*]
#    Username to create in the db. Default is the class title
#
#  [*password*]
#    Password to create in the db. Default is the class title


define midonet_openstack::resources::database (
  $user = getvar("::openstack::config::mysql_user_${title}"),
  $password = getvar("::openstack::config::mysql_pass_${title}"),
) {
  class { "::${title}::db::mysql":
    user          => $user,
    password      => $password,
    dbname        => $title,
    allowed_hosts => $::openstack::config::mysql_allowed_hosts,
    mysql_module  => '2.2',
    require       => Anchor['database-service'],
  }
}
