
#
# Unit tests for midonet_openstack#::resources::firewall
#

require 'spec_helper'

describe 'midonet_openstack#::resources::firewall' do

  let :pre_condition do
    "include ::midonet_openstack::params"

  end

  let :default_params do
    {
        :port => '117'
    }
  end

  shared_examples_for 'add firewall rule' do

    context 'with default params' do
      let :params do
        default_params
      end

      let :title do
       'Open Test Port'
      end

    it 'should add a firewall rule on port 117' do
      is_expected.to contain_firewall('117 - Open Test Port').with(
        'proto'  => 'tcp',
        'state'  => ['NEW','RELATED','ESTABLISHED'],
        'action' => 'accept',
        'sport'  => '117',
        'dport'  => '117',
        'before' => 'Firewall[8999 - Accept all management network traffic]'
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

    it_configures 'add firewall rule'
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

    it_configures 'add firewall rule'
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

    it_configures 'add firewall rule'
  end
end
