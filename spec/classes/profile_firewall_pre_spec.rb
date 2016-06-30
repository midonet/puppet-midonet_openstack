
#
# Unit tests for midonet_openstack::profile::firewall::pre
#

require 'spec_helper'

describe 'midonet_openstack::profile::firewall::pre' do

  let :pre_condition do
    "include ::firewall"
    "include midonet_openstack::profile::firewall::post"

  end

  let :default_params do
    { }
  end

  shared_examples_for 'firewall pre rules' do

    context 'with default params' do
      let :params do
        default_params
      end

    it 'should contain firewallchain' do
      is_expected.to contain_firewallchain('INPUT:filter:IPv4').with(
        'purge'  => 'true',
        'ignore' => ['neutron','virbr0'],
      )
      is_expected.to contain_firewallchain('INPUT:filter:IPv4').that_comes_before(
      "Firewall[0001 - related established]"
      )
      end

    it 'should contain firewall rule for related established' do
      is_expected.to contain_firewall('0001 - related established').with(
        'proto'  => 'all',
        'state'  => ['RELATED', 'ESTABLISHED'],
        'action' => 'accept',
      )
      is_expected.to contain_firewall('0001 - related established').that_comes_before("Class[firewall]")
      is_expected.to contain_firewall('0001 - related established').that_comes_before("Firewall[0002 - localhost]")

      end

      it 'should contain firewall rule for icmp from localhost' do
        is_expected.to contain_firewall('0002 - localhost').with(
          'proto'   => 'icmp',
          'source'  => '127.0.0.1',
          'action'  => 'accept',
        )
        is_expected.to contain_firewall('0002 - localhost').that_comes_before(
          "Firewall[0003 - localhost]")

        end

      it 'should contain firewall rule for all traffic from localhost' do
        is_expected.to contain_firewall('0003 - localhost').with(
          'proto'   => 'all',
          'source'  => '127.0.0.1',
          'action'  => 'accept',
        )
        is_expected.to contain_firewall('0003 - localhost').that_comes_before(
          "Firewall[0022 - ssh]")

        end

      it 'should contain accept ssh traffic' do
        is_expected.to contain_firewall('0022 - ssh').with(
          'proto'  => 'tcp',
          'state'  => ['NEW', 'ESTABLISHED', 'RELATED'],
          'action' => 'accept',
          'dport'  => '22',
        )
        is_expected.to contain_firewall('0022 - ssh').that_comes_before(
          'Firewall[8999 - Accept all management network traffic]')
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

    it_configures 'firewall pre rules'
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

    it_configures 'firewall pre rules'
  end
end
