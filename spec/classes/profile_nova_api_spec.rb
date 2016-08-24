
#
# Unit tests for midonet_openstack::profile::nova::api
#

require 'spec_helper'

describe 'midonet_openstack::profile::nova::api' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'setup nova::api' do

    context 'with default params' do
      let :params do
        default_params
      end



    it 'should configure nova db' do
      is_expected.to contain_class('nova::db::mysql').with(
        'user'      => 'nova',
        'password'  => 'testmido',
      )
      end

    it 'should configure nova_api db' do
      is_expected.to contain_class('nova::db::mysql_api').with(
        'user'      => 'nova_api',
        'password'  => 'testmido',
      )
      end

    it 'should configure nova keystone auth' do
      is_expected.to contain_class('nova::keystone::auth').with(
        'public_url'      => 'http://172.17.0.3:8774/v2.1/%(tenant_id)s',
        'public_url_v3'   => 'http://172.17.0.3:8774/v3/%(tenant_id)s',
        'internal_url'    => 'http://172.17.0.3:8774/v2.1/%(tenant_id)s',
        'internal_url_v3' => 'http://172.17.0.3:8774/v3/%(tenant_id)s',
        'admin_url'       => 'http://172.17.0.3:8774/v2.1/%(tenant_id)s',
        'admin_url_v3'    => 'http://172.17.0.3:8774/v3/%(tenant_id)s',
        'password'        => 'testmido',
        'region'          => 'openstack'
      )
      end

    it 'should create a rabbitmq user for nova' do
      is_expected.to contain_rabbitmq_user('nova').with(
        'admin'    => 'true',
        'password' => 'safe_password',
        'provider' => 'rabbitmqctl',
        'require'  => 'Class[Rabbitmq]',
      )
      end

    it 'should grant permissions for rabbitmq user for nova' do
      is_expected.to contain_rabbitmq_user_permissions('nova@/').with(
        'configure_permission' => '.*',
        'write_permission'     => '.*',
        'read_permission'      => '.*',
        'provider'             => 'rabbitmqctl',
        'require'              => 'Class[Rabbitmq]',
      )
      end

    it 'should install and configure base nove packages' do
      is_expected.to contain_class('nova').with(
        'database_connection'     => 'mysql+pymysql://nova:testmido@127.0.0.1/nova',
        'api_database_connection' => 'mysql+pymysql://nova_api:testmido@127.0.0.1/nova_api',
        'rabbit_hosts'            => ["172.17.0.3:5672"],
        'rabbit_userid'           => 'nova',
        'rabbit_password'         => 'safe_password',
        'glance_api_servers'      => ["172.17.0.3:9292"],
        'memcached_servers'       => ["172.17.0.3:11211"],
        'verbose'                 => 'True',
        'debug'                   => 'True',
        'require'                 => 'Class[Midonet_openstack::Profile::Memcache::Memcache]'
      )
      end

      it 'should configure nova network neutron' do
        is_expected.to contain_class('nova::network::neutron').with(
          'neutron_password'    => 'testmido',
          'neutron_region_name' => 'openstack',
          'neutron_auth_url'    => 'http://172.17.0.3:35357/v3',
        )
        end

      it 'should configure nova vncproxy' do
        is_expected.to contain_class('nova::vncproxy').with(
          'host'       => '172.17.0.3',
          'enabled'    => true,
        )
        end

      it 'should install scheduler, cert, consoleauth & conductor' do
          is_expected.to contain_class('nova::scheduler').with('enabled' => true)
          is_expected.to contain_class('nova::cert').with('enabled' => true)
          is_expected.to contain_class('nova::consoleauth').with('enabled' => true)
          is_expected.to contain_class('nova::conductor').with('enabled' => true)

        end


    end
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
        :operatingsystemmajrelease => '14'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup nova::api'
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
        :operatingsystemmajrelease => '16'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup nova::api'
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
        :operatingsystemmajrelease => '7'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'setup nova::api'
  end
end
