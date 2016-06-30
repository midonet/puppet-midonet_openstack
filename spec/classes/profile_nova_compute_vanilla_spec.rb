
#
# Unit tests for midonet_openstack::profile::nova::compute_vanilla
#

require 'spec_helper'

describe 'midonet_openstack::profile::nova::compute_vanilla' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'setup nova::compute_vanilla' do

    context 'with default params' do
      let :params do
        default_params
      end




    it 'should configure nova compute' do
      is_expected.to contain_class('nova::compute').with(
        'enabled'                       => true,
        'vnc_enabled'                   => true,
        'vncserver_proxyclient_address' => '172.17.0.3',
        'vncproxy_host'                 => '172.17.0.3',
      )
      end

    it 'should configure libvirt' do
      is_expected.to contain_class('nova::compute::libvirt').with(
        'libvirt_virt_type' => 'qemu',
        'vncserver_listen'  => '172.17.0.3',
      )
      end

    it 'should configure libvirt migration' do
      is_expected.to contain_class('nova::compute::libvirt')
      end

    end
end

shared_examples_for 'setup nova::compute_vanilla extra stepts on redhat' do
  it 'should install device mapper' do
    is_expected.to contain_package('device-mapper').with(
      'ensure' => 'latest',
    )
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

    it_configures 'setup nova::compute_vanilla'
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

    it_configures 'setup nova::compute_vanilla'
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

    it_configures 'setup nova::compute_vanilla'
    it_configures 'setup nova::compute_vanilla extra stepts on redhat'
  end
end
