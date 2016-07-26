require 'spec_helper'

describe 'midonet_openstack::profile::neutron::controller_vanilla' do

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
      'require' => 'Class[Rabbitmq]',
      )
    end

    it 'should configure permissions for the neutron RabbitMQ user' do
      is_expected.to contain_rabbitmq_user_permissions('neutron@/').with(
      'configure_permission' => '.*',
      'write_permission' => '.*',
      'read_permission' => '.*',
      'provider' => 'rabbitmqctl',
      'require' => 'Class[Rabbitmq]',
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
      'core_plugin' => 'ml2',
      'service_plugins' => '["router", "metering", "firewall"]',
      'debug' => 'true',
      'verbose' => 'true',
      )
    end

    it 'should install the neutron client' do
      is_expected.to contain_class('neutron::client')
    end

    it 'should install the neutron server' do
      is_expected.to contain_class('neutron::server').with(
      'database_connection' => 'mysql+pymysql://neutron:testmido@127.0.0.1/neutron?charset=utf8',
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

    it 'should configure the ml2 plugin' do
      is_expected.to contain_class('neutron::plugins::ml2').with(
      'type_drivers' => '["vxlan"]',
      'tenant_network_types' => '["vxlan"]',
      'mechanism_drivers' => '["openvswitch"]',
      )
      is_expected.to contain_class('neutron::agents::ml2::ovs').with(
      'enable_tunneling' => 'true',
      'local_ip' => '127.0.0.1',
      'tunnel_types' => '["vxlan"]',
      )
    end


    it 'should configure the neutron lbaas agent' do
      is_expected.to contain_class('neutron::agents::lbaas').with(
      'debug' => 'true',
      )
    end

    it 'should configure the neutron l3 agent' do
      is_expected.to contain_class('neutron::agents::l3').with(
      'debug' => 'true',
      )
    end

    it 'should configure the neutron dhcp agent' do
      is_expected.to contain_class('neutron::agents::dhcp').with(
      'debug' => 'true',
      )
    end

    it 'should configure the neutron metering agent' do
      is_expected.to contain_class('neutron::agents::metering').with(
      'debug' => 'true',
      )
    end

    it 'should configure the notification system options' do
      is_expected.to contain_class('neutron::server::notifications').with(
      'auth_url' => 'http://172.17.0.3:35357',
      'password' => 'testmido',
      'region_name' => 'openstack',
      )
    end

    it 'should configure the neutron fwaas service' do
      is_expected.to contain_class('neutron::services::fwaas').with(
      'enabled' => 'true',
      'driver' => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
      )
    end

    it 'should include the openvswitch ovs puppet class' do
      is_expected.to contain_class('vswitch::ovs')
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
