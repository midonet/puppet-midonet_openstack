# == Class: midonet_openstack::profile::midojava::midojava
#
#  Configure Java
# == Parameters
#
#  [*version*]
#    Java Target Version
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
class midonet_openstack::profile::midojava::midojava(
  $version = 8,
  ) {
    include ::stdlib
    $package_name_redhat = "java-1.${version}.0-openjdk-headless"
    $package_name_debian = "openjdk-${version}-jre-headless"
    case $::osfamily {
      'Debian': {
        include ::apt
          notice ( 'Ubuntu 14.04 Installation. Adding OpenJDK keys')
          apt::key { 'openjdk-r':
            id     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            before => Class['java']
          }

          apt::source {'openjdk-r':
              comment  => 'OpenJDK Repository',
              location => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
              release  => downcase($::lsbdistcodename),
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
        contain java

        file { '/usr/java/default':
          ensure  => 'link',
          target  => '/etc/alternatives/java',
          require => File['/usr/java']
        }

        Class['::apt::update'] -> Package <||>
      }
      'RedHat': {
        class {'::java':
          package => $package_name_redhat,
        }
        contain java

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
