require 'spec_helper'

describe 'midonet_openstack::profile::repos' do

  let :default_params do
    { }
  end

  context 'on Ubuntu 14.04 LTS' do
    let :facts do
      @default_facts.merge({
        :osfamily  => 'Debian',
        :kernel => 'Linux',
        :lsbdistid => 'Ubuntu',
        :lsbdistcodename => 'Trusty'
      })
    end

    it do
      is_expected.to contain_class('openstack_extras::repo::debian::ubuntu').with(
      'release' => 'mitaka',
      'package_require' => 'true',
      )
      is_expected.to contain_apt__pin('ceph').with(
      'priority' => '1001',
      'origin' => 'download.ceph.com'
      )
    end
  end

  context 'on RHEL based platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7',
        :kernel => 'Linux',
        :puppetversion => '3.8.7'
      })
    end

    it do is_expected.to contain_class('openstack_extras::repo::redhat::redhat').with(
      'release' => 'mitaka',
      'manage_epel' => 'false',
      'centos_mirror_url' => 'http://mirror.centos.org',
      'manage_priorities' => 'false'
      )
    end
  end
end
