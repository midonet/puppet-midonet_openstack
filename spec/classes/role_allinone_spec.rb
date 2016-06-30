require 'spec_helper'

describe 'midonet_openstack::role::allinone' do

  let :pre_condition do
    "include ::midonet_openstack::params"
  end

  let :default_params do
    {}
  end

  shared_examples_for 'set up the allinone node' do
    it { is_expected.to contain_class('midonet_openstack::profile::repos') }
    it { is_expected.to contain_class('midonet_openstack::profile::firewall::firewall') }
    it { is_expected.to contain_class('midonet_openstack::profile::rabbitmq::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::mysql::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::memcached::memcached') }
    it { is_expected.to contain_class('midonet_openstack::profile::keystone::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::neutron::controller_vanilla') }
    it { is_expected.to contain_class('midonet_openstack::profile::glance::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::nova::api') }
    it { is_expected.to contain_class('midonet_openstack::profile::nova::compute_vanilla') }
    it { is_expected.to contain_class('midonet_openstack::profile::horizon::horizon') }
  end

  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '14.04',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '14',
        :puppetversion             => '3.8.7',
        :lsbdistid                 => 'Ubuntu',
        :lsbdistcodename           => 'Trusty'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up the allinone node'
  end

  context 'on Ubuntu 16.04' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '16.04',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '16',
        :puppetversion             => '3.8.7',
        :lsbdistid                 => 'Ubuntu',
        :lsbdistcodename           => 'Xenial'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up the allinone node'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '7',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :memorysize                => '2048',
        :interfaces                => 'eth0',
        :ipaddress_eth0            => '172.17.0.3',
        :operatingsystemmajrelease => '7',
        :puppetversion             => '3.8.7',
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'set up the allinone node'
  end
end
