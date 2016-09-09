require 'spec_helper'

describe 'midonet_openstack::profile::zookeeper::midozookeeper' do

  let :pre_condition do
    "include ::midonet_openstack::params"
    "include ::midonet_openstack::profile::midojava::midojava"
    "include ::midonet::repository"
  end

  let :default_params do
    {
      :client_ip  => '172.17.0.3',
      :zk_servers => ['localhost']
    }
  end

  shared_examples_for 'set up zookeeper on Debian' do
    context 'with default params' do
      let :params do
        default_params
      end
     it { is_expected.to contain_class(
       'zookeeper').with(
         'servers'          => ["localhost"],
         'id'               => 1,
         'cfg_dir'          => '/etc/zookeeper/conf',
         'client_ip'        => '172.17.0.3',
         'packages'         => ['zookeeper','zookeeperd'],
         'service_name'     => 'zookeeper',
       ).that_requires('Class[midonet::repository]')
      }
   end

  end

  shared_examples_for 'set up zookeeper on RedHat' do
    context 'with default params' do
      let :params do
        default_params
      end
     it { is_expected.to contain_class(
       'zookeeper').with(
         'servers'          => ["localhost"],
         'id'               => 1,
         'cfg_dir'          => '/etc/zookeeper/conf',
         'client_ip'        => '172.17.0.3',
         'packages'         => ['zookeeper'],
         'service_name'     => 'zookeeper',
       ).that_requires('Class[midonet::repository]')
      }
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

    it_configures 'set up zookeeper on Debian'
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

    it_configures 'set up zookeeper on Debian'
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

    it_configures 'set up zookeeper on RedHat'
  end
end
