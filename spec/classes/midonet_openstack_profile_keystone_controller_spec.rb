require 'spec_helper'

describe 'midonet_openstack::profile::keystone::controller' do
  let :default_params do
    {}
  end
  let :pre_condition do
    "include ::midonet_openstack::params"
  end

  shared_examples_for 'keystone (auth service)' do
    it 'should contain the openstack_integration::params class' do
      is_expected.to contain_class('openstack_integration::params')
    end

    it 'should contain the openstack_integration::config class' do
      is_expected.to contain_class('openstack_integration::config')
    end

    it 'should contain the apache class' do
      is_expected.to contain_class('apache')
    end

    it 'should install the keystone client' do
      is_expected.to contain_class('keystone::client')
    end

    it 'should enable the cronjob to flush expired keystone tokens' do
      is_expected.to contain_class('keystone::cron::token_flush')
    end

    it 'should populate the "keystone" MySQL database' do
      is_expected.to contain_class('keystone::db::mysql').with(
      'password' => 'testmido',
      )
    end

    it 'should configure keystone' do
      is_expected.to contain_class('keystone').with(
        'debug'               => 'true',
        'database_connection' => 'mysql+pymysql://keystone:testmido@127.0.0.1/keystone',
        'admin_token'         => 'testmido',
        'enabled'             => 'true',
        'service_name'        => 'httpd',
        'default_domain'      => nil,
        'using_domain_config' => 'false',
        'enable_ssl'          => 'false',
        'public_bind_host'    => '0.0.0.0',
        'admin_bind_host'     => '0.0.0.0',
        'manage_policyrcd'    => 'true',
        'token_provider'      => 'uuid',
        'enable_fernet_setup' => 'false',
        'memcache_servers'    => '["127.0.0.1:11211"]',
        'require'             => 'Class[Midonet_openstack::Profile::Memcached::Memcached]',
      )
    end

    it 'should configure httpd for keystone' do
      is_expected.to contain_class('keystone::wsgi::apache').with(
        'bind_host'           => nil,
        'admin_bind_host'     => nil,
        'ssl'                 => 'false',
        'workers'             => '2',
      )
    end
  end

  context 'on Ubuntu 14.04' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux',
        :concat_basedir         => '/var/packages',
        :operatingsystemrelease => '14.04',
        :operatingsystem => 'Ubuntu',
        :operatingsystemmajrelease => '14',
        :ipaddress         => '127.0.0.1',
        :fqdn         => '',
        })
      end

      it_configures 'keystone (auth service)'
    end

  context 'on Ubuntu 16.04' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux',
        :concat_basedir         => '/var/packages',
        :operatingsystemrelease => '14.04',
        :operatingsystem => 'Ubuntu',
        :operatingsystemmajrelease => '16',
        :ipaddress         => '127.0.0.1',
        :fqdn         => '',
        })
      end

      it_configures 'keystone (auth service)'
    end

    context 'on RHEL based platforms' do
      let :facts do
        @default_facts.merge({
          :osfamily => 'RedHat',
          :operatingsystemrelease => '7',
          :kernel => 'Linux',
          :concat_basedir         => '/var/packages',
          :ipaddress         => '127.0.0.1',
          :fqdn         => '',
          })
        end

      it_configures 'keystone (auth service)'
    end
end
