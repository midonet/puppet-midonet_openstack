
#
# Unit tests for midonet_openstack::profile::horizon::horizon
#

require 'spec_helper'

describe 'midonet_openstack::profile::horizon::horizon' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'setup horizon' do

    context 'with default params' do
      let :params do
        default_params
      end

    it 'should setup horizon' do
      is_expected.to contain_class('horizon').with(
        'keystone_multidomain_support' => true,
        'server_aliases'               => ['tests.midokura.com',
                                            '172.17.0.3',
                                            '172.17.0.3',
                                            'localhost',
                                            '127.0.0.1'],
        'cache_backend'                => 'django.core.cache.backends.memcached.MemcachedCache',
        'cache_server_ip'              => ['172.17.0.3'],
        'cache_server_port'            => '11211',
        'keystone_url'                 => 'http://127.0.0.1:5000/v3/',
        'secret_key'                   => 'testmido',
        'vhost_extra_params'           => { 'add_listen' => false },
        'keystone_default_role'        => 'user',
        'allowed_hosts'                => ['*',],
        'neutron_options'              => {
                                          'enable_lb' => true,
                                        },
        'compress_offline'             => false,
      )
      end

    end
end

  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :operatingsystemrelease => '14.04',

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup horizon'
  end

  context 'on Ubuntu 16.04' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :operatingsystemrelease => '16.04',

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup horizon'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup horizon'
  end
end
