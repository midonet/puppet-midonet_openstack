# == Class: midonet_openstack::profile::rabbitmq::controller
#
#  Configure RabbitMQ on a controller node
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
class midonet_openstack::profile::rabbitmq::controller {

  include ::openstack_integration::params
  include ::openstack_integration::config

  ##midonet_openstack#::resources::firewall { 'Rabbitmq': port => '5672', }

  ## Dirty workaround until the guys from puppetlabs make new release
  ## with correct apt key for rabbitmq..
  if ($::osfamily == 'Debian') or ($::osfamily == 'Debian')
  {
    apt::key { 'rabbitmq':
      key        => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
      key_source => 'https://www.rabbitmq.com/rabbitmq-release-signing-key.asc',
      before     => Class['::rabbitmq']
      } ->
      exec { 'update_apt_for_rabbitmq':
          command   => '/usr/bin/apt-get update',
          logoutput => 'on_failure',
        }
  }

  if $::midonet_openstack::params::rabbitmq_ssl {

    file { '/etc/rabbitmq/ssl/private':
      ensure                  => directory,
      owner                   => 'root',
      mode                    => '0755',
      selinux_ignore_defaults => true,
      before                  => File["/etc/rabbitmq/ssl/private/${::fqdn}.pem"],
    }

    openstack_integration::ssl_key { 'rabbitmq':
      key_path => "/etc/rabbitmq/ssl/private/${::fqdn}.pem",
      require  => File['/etc/rabbitmq/ssl/private'],
      notify   => Service['rabbitmq-server'],
    }

    class { '::rabbitmq':
      package_provider      => $::package_provider,
      delete_guest_user     => $midonet_openstack::params::rabbitmq_delete_guest_user,
      ssl                   => $midonet_openstack::params::rabbitmq_ssl,
      ssl_only              => $midonet_openstack::params::rabbitmq_ssl_only,
      ssl_cacert            => $::openstack_integration::params::ca_bundle_cert_path,
      ssl_cert              => $::openstack_integration::params::cert_path,
      ssl_key               => "/etc/rabbitmq/ssl/private/${::fqdn}.pem",
      environment_variables => $::openstack_integration::config::rabbit_env,
      repos_ensure          => $midonet_openstack::params::rabbitmq_repos_ensure,
    }
  } else {
    class { '::rabbitmq':
      package_provider      => $::package_provider,
      delete_guest_user     => $midonet_openstack::params::rabbitmq_delete_guest_user,
      environment_variables => $::openstack_integration::config::rabbit_env,
      repos_ensure          => $midonet_openstack::params::rabbitmq_repos_ensure,
    }
  }

  rabbitmq_vhost { '/':
  provider => 'rabbitmqctl',
  require  => [Class['::rabbitmq'],Anchor[rabbitmq::end]] ,
  }

}
