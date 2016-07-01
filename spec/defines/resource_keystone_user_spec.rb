
#
# Unit tests for midonet_openstack::resources::keystone_user
#

require 'spec_helper'

describe 'midonet_openstack::resources::keystone_user' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :admin_params do
    {
        :password => 'super_secure_pwd',
        :tenant   => 'tenant',
        :email    => 'tests@midokura.com',
        :admin    => true,
        :enabled  => true
    }
  end

  let :poor_guy_params do
    {
        :password => 'super_secure_pwd',
        :tenant   => 'tenant',
        :email    => 'tests@midokura.com',
        :admin    => false,
        :enabled  => true
    }
  end

  shared_examples_for 'add a keystone admin user and give its permissions' do

    context 'with default params' do
      let :params do
        admin_params
      end

      let :title do
       'midogod'
      end

    it 'should add a user called midogod' do
      is_expected.to contain_keystone_user('midogod').with(
        'ensure'   => 'present',
        'enabled'  => true,
        'password' => 'super_secure_pwd',
        'email'    => 'tests@midokura.com',
      )
    end

    it 'should add grant admin rights to midogod' do
      is_expected.to contain_keystone_user_role('midogod@tenant').with(
        'ensure'   => 'present',
        'roles'    => ['user','admin'],
      )


      end
    end
  end

  shared_examples_for 'add a normal user and give its permissions' do

    context 'with default params' do
      let :params do
        poor_guy_params
      end

      let :title do
       'midouser'
      end

    it 'should add a user called midouser' do
      is_expected.to contain_keystone_user('midouser').with(
        'ensure'   => 'present',
        'enabled'  => true,
        'password' => 'super_secure_pwd',
        'email'    => 'tests@midokura.com',
      )
    end

    it 'should add grant user rights to midouser' do
      is_expected.to contain_keystone_user_role('midouser@tenant').with(
        'ensure'   => 'present',
        'roles'    => ['user'],
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

    it_configures 'add a keystone admin user and give its permissions'
    it_configures 'add a normal user and give its permissions'
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

    it_configures 'add a keystone admin user and give its permissions'
    it_configures 'add a normal user and give its permissions'
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

    it_configures 'add a keystone admin user and give its permissions'
    it_configures 'add a normal user and give its permissions'
  end
end
