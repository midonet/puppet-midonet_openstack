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
        'public_bind_host'    => '172.17.0.3',
        'admin_bind_host'     => '172.17.0.3',
        'manage_policyrcd'    => 'true',
        'token_provider'      => 'uuid',
        'enable_fernet_setup' => 'false',
        'memcache_servers'    => '["172.17.0.3:11211"]',
        'require'             => 'Class[Midonet_openstack::Profile::Memcache::Memcache]',
      )
    end

    it 'should configure httpd for keystone' do
      is_expected.to contain_class('keystone::wsgi::apache').with(
        'bind_host'           => '172.17.0.3',
        'admin_bind_host'     => '172.17.0.3',
        'ssl'                 => 'false',
        'workers'             => '2',
      )
    end

    it 'should create the role admin in keystone' do
      is_expected.to contain_class('keystone::roles::admin').with(
        'email'                => 'mido-dev@lists.midonet.org',
        'password'             => 'testmido',
      )
    end

    it 'should register the keystone endpoint in openstack' do
      is_expected.to contain_class('keystone::endpoint').with(
        'default_domain' => nil,
        'public_url'     => 'http://172.17.0.3:5000',
        'admin_url'      => 'http://172.17.0.3:35357',
        'region'         => 'openstack',
        'require'        => '[Class[Keystone]{:name=>"Keystone"}, Class[Keystone::Wsgi::Apache]{:name=>"Keystone::Wsgi::Apache"}]',
      )
    end

    it 'should create an adminrc.sh file' do
      is_expected.to contain_class('openstack_extras::auth_file').with(
        'password'        => 'testmido',
        'project_domain'  => 'default',
        'user_domain'     => 'default',
        'auth_url'        => 'http://172.17.0.3:5000/v3/',
      )
    end

    it 'should create an initial set of keystone tenants' do
      is_expected.to contain_keystone_tenant('midokura').with(
      'description' => 'Test Tenant',
      )
    end

    it 'should create a "user" keystone role' do
      is_expected.to contain_keystone_role('user').with(
      'ensure' => 'present',
      )
    end

    it 'should create an initial set of keystone users' do
      is_expected.to contain_midonet_openstack__resources__keystone_user('midogod').with(
      'password' => 'midogod',
      'tenant'   => 'midokura',
      'email'    => 'foo@midokura.com',
      'admin'    => 'true',
      )
      is_expected.to contain_midonet_openstack__resources__keystone_user('midoguy').with(
      'password' => 'midoguy',
      'tenant'   => 'midokura',
      'email'    => 'bar@midokura.com',
      'admin'    => 'false',
      )
      is_expected.to contain_midonet_openstack__resources__keystone_user('midonet').with(
      'password' => 'testmido',
      'tenant'   => 'services',
      'email'    => 'midonet@midokura.com',
      'admin'    => 'true',
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
        :ipaddress         => '172.17.0.3',
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
        :ipaddress         => '172.17.0.3',
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
          :ipaddress         => '172.17.0.3',
          :fqdn         => '',
          })
        end

      it_configures 'keystone (auth service)'
    end
end
