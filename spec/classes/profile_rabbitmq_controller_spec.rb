
#
# Unit tests for midonet_openstack::profile::rabbitmq::controller
#

require 'spec_helper'

describe 'midonet_openstack::profile::rabbitmq::controller' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'setup rabbitmq on debian' do

    context 'with default params' do
      let :params do
        default_params
      end

    it 'should add rabbitmq apt key' do
      is_expected.to contain_apt__key('rabbitmq').with(
        'key'        => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
        'key_source' => 'https://www.rabbitmq.com/rabbitmq-release-signing-key.asc',
      ).that_comes_before('Class[rabbitmq]').that_comes_before(
        'Exec[update_apt_for_rabbitmq]')
      end

    it 'should refresh apt after adding key' do
      is_expected.to contain_exec('update_apt_for_rabbitmq').with(
        'command'   => '/usr/bin/apt-get update',
        'logoutput' => 'on_failure',
      )
      end

    it 'should setup rabbitmq' do
      is_expected.to contain_class('rabbitmq').with(
        'package_provider'      => 'apt',
        'delete_guest_user'     => 'true',
        'environment_variables' => {},
        'repos_ensure'          => true,
      )
      end

    it 'should setup rabbitmq vhost' do
      is_expected.to contain_rabbitmq_vhost('/').with(
        'provider'      => 'rabbitmqctl',
      ).that_requires('Class[Rabbitmq]')
      end

    end
  end

shared_examples_for 'setup rabbitmq on redhat' do

  context 'with default params' do
    let :params do
      default_params
    end

    it 'should setup rabbitmq' do
      is_expected.to contain_class('rabbitmq').with(
        'delete_guest_user'     => 'true',
        'environment_variables' => {},
        'repos_ensure'          => true,
      )
      end

    it 'should setup rabbitmq vhost' do
      is_expected.to contain_rabbitmq_vhost('/').with(
        'provider'      => 'rabbitmqctl',
      ).that_requires('Class[Rabbitmq]')
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
        :memorysize             => '2048',
        :lsbdistid              => 'trusty'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup rabbitmq on debian'
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
        :memorysize             => '2048',
        :lsbdistid              => 'xenial'


      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup rabbitmq on debian'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '7',
        :operatingsystemmajrelease => '7',
        :kernel                    => 'Linux',
        :ipaddress                 => '172.17.0.3',
        :concat_basedir            => '/var/packages',
        :fqdn                      => 'tests.midokura.com',
        :memorysize                => '2048'
      })
    end

    let :platform_params do
      {}
    end
    it_configures 'setup rabbitmq on redhat'
  end
end
