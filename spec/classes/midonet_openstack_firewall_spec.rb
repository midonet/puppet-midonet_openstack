
#
# Unit tests for midonet_openstack::profile::firewall::firewall
#

require 'spec_helper'

describe 'midonet_openstack::profile::firewall::firewall' do

  let :default_params do
    { }
  end

  shared_examples_for 'firewall basic rules' do

    context 'with default params' do
      let :params do
        default_params
      end

      it 'should contain firewall pre and post classes' do
        is_expected.to contain_class('midonet_openstack::profile::firewall::pre')
        is_expected.to contain_class('midonet_openstack::profile::firewall::post')
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

    it_configures 'firewall basic rules'
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

    it_configures 'firewall basic rules'
  end
end
