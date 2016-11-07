require 'spec_helper'

describe 'midonet_openstack::profile::neutron::compute' do

  let :default_params do
    {
      :controller_management_address        => '172.17.0.3',
      :controller_api_address               => '80.80.80.80',
      :region_name                          => 'kanto',
      :neutron_password                     => 'beam_me_up_scotty'
    }
  end
  let :pre_condition do

  end

  shared_examples_for 'neutron compute' do
    let :params do
      {
        :controller_management_address        => '172.17.0.3',
        :controller_api_address               => '80.80.80.80',
        :region_name                          => 'kanto',
        :neutron_password                     => 'beam_me_up_scotty'
      }
    end

    it 'should configure nova config' do
      is_expected.to contain_nova_config('neutron/auth_url').with_value('http://80.80.80.80:5000')
      is_expected.to contain_nova_config('neutron/auth_plugin').with_value('password')
      is_expected.to contain_nova_config('neutron/user_domain_id').with_value('default')
      is_expected.to contain_nova_config('neutron/region_name').with_value('kanto')
      is_expected.to contain_nova_config('neutron/project_name').with_value('admin')
      is_expected.to contain_nova_config('neutron/username').with_value('neutron')
      is_expected.to contain_nova_config('neutron/password').with_value('beam_me_up_scotty')
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

      it_configures 'neutron compute'
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

      it_configures 'neutron compute'
    end

end
