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
    it { is_expected.to contain_class('midonet_openstack::profile::rabbitmq::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::mysql::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::memcache::memcache') }
    it { is_expected.to contain_class('midonet_openstack::profile::keystone::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::neutron::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::glance::controller') }
    it { is_expected.to contain_class('midonet_openstack::profile::nova::api') }
    it { is_expected.to contain_class('midonet_openstack::profile::nova::compute') }
    it { is_expected.to contain_class('midonet_openstack::profile::horizon::horizon') }
    it { is_expected.to contain_class('midonet_openstack::profile::midojava::midojava') }
    it { is_expected.to contain_class('midonet_openstack::profile::zookeeper::midozookeeper').with(
      'zk_servers' => ['localhost'],
      'id'         => 1,
      'client_ip'  => '172.17.0.3',
      ) }
    it { is_expected.to contain_class('midonet_openstack::profile::cassandra::midocassandra').with(
      'seeds'               => ['172.17.0.3'],
      'seed_address'        => '172.17.0.3',
      'storage_port'        => '7000',
      'ssl_storage_port'    => '7001',
      'client_port'         => '9042',
      'client_port_thrift'  => '9160',
      ) }

  end

  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :hostname                  => 'tests',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '14.04',
        :lsbdistrelease            => '14.04',
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
        :hostname                  => 'tests',
        :fqdn                      => 'tests.midokura.com',
        :operatingsystemrelease    => '16.04',
        :lsbdistrelease            => '16.04',
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
        :operatingsystem           => 'CentOS',
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
