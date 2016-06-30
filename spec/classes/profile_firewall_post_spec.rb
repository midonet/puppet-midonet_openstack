
#
# Unit tests for midonet_openstack::profile::firewall::post
#

require 'spec_helper'

describe 'midonet_openstack::profile::firewall::post' do

  let :pre_condition do
    "include ::firewall"
    "include ::midonet_openstack::params"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'firewall post rules' do

    context 'with default params' do
      let :params do
        default_params
      end

    it 'should contain firewall rule for accepting all mgmt traffic' do
      is_expected.to contain_firewall(
      '8999 - Accept all management network traffic').with(
        'proto'  => 'all',
        'state'  => ['NEW'],
        'action' => 'accept',
        'source' => '172.17.0.0/24',
      )
      is_expected.to contain_firewall(
      '8999 - Accept all management network traffic').that_comes_before(
      "Firewall[9100 - Accept all vm network traffic]")
      end

    it 'should contain firewall rule for accepting all vm traffic' do
      is_expected.to contain_firewall(
      '9100 - Accept all vm network traffic').with(
        'proto'  => 'all',
        'state'  => ['NEW'],
        'action' => 'accept',
        'source' => '172.17.0.0/24',
      )
      is_expected.to contain_firewall(
      '9100 - Accept all vm network traffic').that_comes_before(
      "Firewall[9999 - Reject remaining traffic]")
      end

      it 'should contain firewall rule for rejecting remaining traffic' do
        is_expected.to contain_firewall(
        '9999 - Reject remaining traffic').with(
          'proto'  => 'all',
          'action' => 'reject',
          'reject' => 'icmp-host-prohibited',
          'source' => '0.0.0.0/0',
        )
        end

    end
end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel    => 'Linux'

      })
    end

    let :platform_params do
      {}
    end

    it_configures 'firewall post rules'
  end

  context 'on Red Hat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7',
        :kernel   => 'Linux'
      })
    end

    let :platform_params do
      {}
    end

    it_configures 'firewall post rules'
  end
end
