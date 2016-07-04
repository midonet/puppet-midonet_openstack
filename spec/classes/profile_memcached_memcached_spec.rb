
#
# Unit tests for midonet_openstack::profile::memcache::memcache
#

require 'spec_helper'

describe 'midonet_openstack::profile::memcache::memcache' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'setup memcached' do

    context 'with default params' do
      let :params do
        default_params
      end

    it 'should setup memcached' do
      is_expected.to contain_class('memcached').with(
        'listen_ip' => '172.17.0.3',
        'tcp_port'  => '11211',
        'udp_port'  => '11211',
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
        :memorysize             => '2048'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup memcached'
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
        :memorysize             => '2048'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup memcached'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7',
        :kernel                 => 'Linux',
        :ipaddress              => '172.17.0.3',
        :concat_basedir         => '/var/packages',
        :fqdn                   => 'tests.midokura.com',
        :memorysize             => '2048'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup memcached'
  end
end
