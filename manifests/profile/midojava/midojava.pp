# == Class: midonet_openstack::profile::midojava::midojava
#
#  Configure Java
# == Parameters
#
#  [*version*]
#    Java Target Version
class midonet_openstack::profile::midojava::midojava(
  $version = 8,
  ) {
    $package_name_debian = "openjdk-${version}-jdk-headless"
    $package_name_redhat = "java-1.${version}.0-openjdk-headless"
    case $::osfamily {
      'Debian': {
        include ::apt
        if $::lsbdistrelease == '16.04' {
          # Placeholder so the default case does not fail
        }
        elsif $::lsbdistrelease == '14.04' {
          notice ( 'Ubuntu 14.04 Installation. Adding OpenJDK keys')
          apt::key { 'openjdk-r':
            id     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            before => Class['java']
          }

          apt::source {'openjdk-r':
              comment  => 'OpenJDK Repository',
              location => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
              release  => 'trusty',
              key      => {
                    'id'     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
                    'server' => 'subkeys.pgp.net',
              },
              include  => {
                    'src' => false,
              },
              before   => Class['java'],
              notify   => Class['::apt::update']
          }
        }
        else {
          fail("Can't manage Java on ${::lsbdistid} ${::lsbdistrelease}")
        }
      }
      'RedHat': {
        # Placeholder so the default case does not fail
      }
      default: {
        fail("Java cannot be managed on ${::osfamily}-based systems")
      }
    }

    case $::osfamily {
      'Debian': {
        class {'::java':
          package               => $package_name_debian,
          java_alternative      => "java-1.${version}.0-openjdk-amd64",
          java_alternative_path => "/usr/lib/jvm/java-1.${version}.0-openjdk-amd64"
        }
        contain '::java'

        file { '/usr/java/default':
          ensure  => 'link',
          target  => '/etc/alternatives/java',
          require => File['/usr/java']
        }

        Class['::apt::update'] -> Package <||>
      }
      'RedHat': {
        class {'::java':
          package               => $package_name_redhat,
        }
        contain '::java'

        file { '/usr/java/default':
          ensure  => 'link',
          target  => "/etc/alternatives/jre_1.${version}.0",
          require => File['/usr/java']
        }

      }
      default: {
        fail("Unsupported platform ${::osfamily}")
      }


    }

    file { '/usr/java':
      ensure  => 'directory',
      require => Class['java']
    }



}
