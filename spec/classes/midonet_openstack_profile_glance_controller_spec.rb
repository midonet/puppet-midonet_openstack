require 'spec_helper'

describe 'midonet_openstack::profile::glance::controller' do

  let :default_params do
    { }
  end
  let :pre_condition do
    "include ::midonet_openstack::params"
  end

  shared_examples_for 'glance (image service)' do
    it 'should contain the openstack_integration::params class' do
      is_expected.to contain_class('openstack_integration::params')
    end

    it 'should contain the openstack_integration::config class' do
      is_expected.to contain_class('openstack_integration::config')
    end

    it 'should create the "glance" rabbitmq user' do
      is_expected.to contain_rabbitmq_user('glance').with(
      'admin' => 'true',
      'password' => 'safe_password',
      'provider' => 'rabbitmqctl',
      'require' => 'Class[Rabbitmq]'
      )
    end

    it 'should set the "glance" rabbitmq user permissions' do
      is_expected.to contain_rabbitmq_user_permissions('glance@/').with(
      'configure_permission' => '.*',
      'write_permission' => '.*',
      'read_permission' => '.*',
      'provider' => 'rabbitmqctl',
      'require' => 'Class[Rabbitmq]'
      )
    end

    it 'should populate the "glance" MySQL database' do
      is_expected.to contain_class('glance::db::mysql').with(
      'password' => 'testmido',
      'allowed_hosts' => '%',
      )
    end

    it 'should configure glance' do
      is_expected.to contain_class('glance')
    end

    it 'should install the glance client' do
      is_expected.to contain_class('glance::client')
    end

    it 'should create the glance user in keystone' do
      is_expected.to contain_class('glance::keystone::auth').with(
      'password' => 'midokura',
      'region' => 'openstack',
      )
    end

    it 'should configure glance to use the file backend' do
      is_expected.to contain_class('glance::backend::file')
    end

    it 'should configure the glance API' do
      is_expected.to contain_class('glance::api').with(
      'debug'                     => 'true',
      'database_connection'       => "mysql+pymysql://glance:testmido@127.0.0.1/glance?charset=utf8",
      'keystone_password'         => 'midokura',
      'workers'                   => '2',
      'stores'                    => '["http", "file"]',
      'default_store'             => 'file',
      'bind_host'                 => '0.0.0.0',
      'auth_uri'                  => 'http://127.0.0.1:5000',
      'identity_uri'              => 'http://127.0.0.1:35357',
      'registry_client_protocol'  => 'http',
      'registry_client_cert_file' => '<SERVICE DEFAULT>',
      'registry_client_key_file'  => '<SERVICE DEFAULT>',
      'registry_host'             => '0.0.0.0',
      'cert_file'                 => '<SERVICE DEFAULT>',
      'key_file'                  => '<SERVICE DEFAULT>',
      'os_region_name'            => 'openstack',
      )
    end

    it 'should configure the glance registry' do
      is_expected.to contain_class('glance::registry').with(
      'debug'                     => 'true',
      'database_connection'       => 'mysql+pymysql://glance:testmido@127.0.0.1/glance?charset=utf8',
      'keystone_password'         => 'midokura',
      'workers'                   => '2',
      'bind_host'                 => '0.0.0.0',
      'auth_uri'                  => 'http://127.0.0.1:5000',
      'identity_uri'              => 'http://127.0.0.1:35357',
      'cert_file'                 => 'false',
      'key_file'                  => 'false',
      'os_region_name'            => 'openstack',
      )
    end

    it 'should configure rabbitmq notifications for glance' do
      is_expected.to contain_class('glance::notify::rabbitmq').with(
      'rabbit_userid'             => 'glance',
      'rabbit_password'           => 'safe_password',
      'rabbit_host'               => 'localhost',
      'rabbit_port'               => '5672',
      'notification_driver'       => 'messagingv2',
      'rabbit_use_ssl'            => 'false',
      )
    end
  end

  context 'on Debian based platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux'
        })
      end

      it_configures 'glance (image service)'
    end

    context 'on RHEL based platforms' do
      let :facts do
        @default_facts.merge({
          :osfamily => 'RedHat',
          :operatingsystemrelease => '7',
          :kernel => 'Linux'
          })
        end

      it_configures 'glance (image service)'
    end
end
