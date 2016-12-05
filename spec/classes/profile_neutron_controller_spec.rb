require 'spec_helper'

describe 'midonet_openstack::profile::neutron::controller' do

  let :default_params do
    { }
  end
  let :pre_condition do
    "include ::midonet_openstack::params"
  end

  shared_examples_for 'neutron (networking service)' do
    it 'should contain the openstack_integration::config class' do
      is_expected.to contain_class('openstack_integration::config')
    end

    it 'should create a RabbitMQ user for neutron' do
      is_expected.to contain_rabbitmq_user('neutron').with(
      'admin' => 'true',
      'password' => 'safe_password',
      'provider' => 'rabbitmqctl',
      )
    end

    it 'should configure permissions for the neutron RabbitMQ user' do
      is_expected.to contain_rabbitmq_user_permissions('neutron@/').with(
      'configure_permission' => '.*',
      'write_permission' => '.*',
      'read_permission' => '.*',
      'provider' => 'rabbitmqctl',
      )
    end

    it 'shoud create a MySQL user for neutron' do
      is_expected.to contain_class('neutron::db::mysql').with(
      'password' => 'testmido',
      'allowed_hosts' => '%',
      )
    end

    it 'shoud create a keystone user for neutron' do
      is_expected.to contain_class('neutron::keystone::auth').with(
      'password' => 'testmido',
      'region' => 'openstack',
      )
    end

    it 'should configure the neutron service' do
      is_expected.to contain_class('neutron').with(
      'rabbit_user' => 'neutron',
      'rabbit_password' => 'safe_password',
      'rabbit_hosts' => ['172.17.0.3:5672'],
      'rabbit_use_ssl' => 'false',
      'allow_overlapping_ips' => 'true',
      'core_plugin' => 'midonet.neutron.plugin_v2.MidonetPluginV2',
      'service_plugins' => [
        'midonet.neutron.services.firewall.plugin.MidonetFirewallPlugin',
        'lbaas',
        'midonet.neutron.services.l3.l3_midonet.MidonetL3ServicePlugin'
        ],
      'debug' => 'true',
      'verbose' => 'true',
      )
    end

    it 'should install the neutron client' do
      is_expected.to contain_class('neutron::client')
    end

    it 'should install the neutron server' do
      is_expected.to contain_class('neutron::server').with(
      'database_connection' => 'mysql+pymysql://neutron:testmido@172.17.0.3/neutron?charset=utf8',
      'password' => 'testmido',
      'sync_db' => 'true',
      'api_workers' => '2',
      'rpc_workers' => '2',
      'auth_uri' => 'http://172.17.0.3:5000',
      'auth_url' => 'http://172.17.0.3:35357',
      'region_name' => 'openstack',
      'auth_region' => 'openstack',
      )
    end


  end

  context 'on Debian based platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux',
        :ipaddress => '172.17.0.3',

        })
      end

      it_configures 'neutron (networking service)'
    end

    context 'on RHEL based platforms' do
      let :facts do
        @default_facts.merge({
          :osfamily => 'RedHat',
          :operatingsystemrelease => '7',
          :kernel => 'Linux',
          :ipaddress => '172.17.0.3',
          })
        end

      it_configures 'neutron (networking service)'
    end

end
