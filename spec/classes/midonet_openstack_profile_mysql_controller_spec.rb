require 'spec_helper'

describe 'midonet_openstack::profile::mysql::controller' do

  let :default_params do
    { }
  end

  shared_examples_for 'mysql database' do
    context 'with default params' do
      let :params do
        default_params
      end

      it 'should contain the puppelabs-mysql class' do
        is_expected.to contain_class('mysql::server')
      end
    end
  end

  context 'on Debian based platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux'
        })
      end

      it_configures 'mysql database'
    end

    context 'on RHEL based platforms' do
      let :facts do
        @default_facts.merge({
          :osfamily => 'RedHat',
          :operatingsystemrelease => '7',
          :kernel => 'Linux'
          })
        end

        it_configures 'mysql database'
      end
    end
