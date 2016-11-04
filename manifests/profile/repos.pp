# == Class: midonet_openstack::profile::repos
#
#  Configure OpenStack Mitaka repositories on a given node
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
class midonet_openstack::profile::repos{
  case $::osfamily {
    'Debian': {
      if $::lsbdistrelease == '16.04' {
        # Placeholder so the default case does not fail
      }
      else {
        include ::apt
        class { '::openstack_extras::repo::debian::ubuntu':
        release         => 'mitaka',
        package_require => true,
        }
    }
    # Ceph is both packaged on UCA & ceph.com
    # Official packages are on ceph.com so we want to make sure
    # Ceph will be installed from there.
    apt::pin { 'ceph':
      priority => 1001,
      origin   => 'download.ceph.com',
    }
  }
  'RedHat': {
    class { '::openstack_extras::repo::redhat::redhat':
      release           => 'mitaka',
      manage_epel       => false,
      centos_mirror_url => $::nodepool_mirror_host,
      manage_priorities => false,
    }
  }
  default: {
    fail("Unsupported osfamily (${::osfamily})")
  }
}

# On CentOS, deploy Ceph using SIG repository and get rid of EPEL.
# https://wiki.centos.org/SpecialInterestGroup/Storage/
if $::operatingsystem == 'CentOS' {
  $enable_sig  = true
  $enable_epel = false
  } else {
    $enable_sig  = false
    $enable_epel = true
  }

  class { '::ceph::repo':
  enable_sig  => $enable_sig,
  enable_epel => $enable_epel,
}
}
