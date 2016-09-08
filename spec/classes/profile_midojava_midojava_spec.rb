require 'spec_helper'

describe 'midonet_openstack::profile::midojava::midojava' do

  let :pre_condition do
    "include ::midonet_openstack::params"
    "include ::midonet::repository"
  end

  let :default_params do
    {
    }
  end

  shared_examples_for 'set up java on Debian' do
    context 'with default params' do
      let :params do
        default_params
      end


     it { is_expected.to contain_class(
       'java').with(
         'package'               => 'openjdk-8-jre-headless',
         'java_alternative'      => 'java-1.8.0-openjdk-amd64',
         'java_alternative_path' => '/usr/lib/jvm/java-1.8.0-openjdk-amd64'
       )
      }

      it { is_expected.to contain_file(
        '/usr/java/default').with(
          'ensure'                => 'link',
          'target'                => '/etc/alternatives/java',
        ).that_requires('File[/usr/java]')
       }

       it { is_expected.to contain_file(
         '/usr/java').with(
           'ensure'                => 'directory',
         ).that_requires('Class[java]')
        }

   end

  end

  shared_examples_for 'set up java on RedHat' do
    context 'with default params' do
      let :params do
        default_params
      end

      it { is_expected.to contain_file(
        '/usr/java/default').with(
          'ensure'                => 'link',
          'target'                => '/etc/alternatives/jre_1.8.0',
        ).that_requires('File[/usr/java]')
       }

       it { is_expected.to contain_class(
         'java').with(
           'package'               => 'java-1.8.0-openjdk-headless',
         )
        }
   end

  end


  shared_examples_for 'Ubuntu 14.04 extra config' do
    context 'with default params' do
      let :params do
        default_params
      end
      it { is_expected.to contain_apt__key(
        'openjdk-r').with(
          'id' => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
        )
       }

       it { is_expected.to contain_apt__source(
         'openjdk-r').with(
             'comment'  => 'OpenJDK Repository',
             'location' => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
             'release'  => 'trusty',
             'key'      => {
                 'id'     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
                 'server' => 'subkeys.pgp.net',
               },
               'include' => {
                 'src' => false,
               }
          )
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

    it_configures 'set up java on Debian'
    it_configures 'Ubuntu 14.04 extra config'
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

    it_configures 'set up java on Debian'
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

    it_configures 'set up java on RedHat'
  end
end
