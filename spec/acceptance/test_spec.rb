require 'spec_helper_acceptance'

describe 'midonet_openstack class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
        include ::midonet_openstack::role::allinone
      EOS

      # Run it twice and test for idempotency
      #expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    # **************************************************************************
    # PORT TESTING
    # **************************************************************************

    # Keystone
    describe port(5000) do
      it { is_expected.to be_listening }
    end
    describe port(35357) do
      it { is_expected.to be_listening }
    end
    # Nova
    describe port(8774) do
      it { is_expected.to be_listening }
    end
    describe port(8775) do
      it { is_expected.to be_listening }
    end
    # VNC proxy
    describe port(6080) do
      it { is_expected.to be_listening }
    end
    # Glance
    describe port(9292) do
      it { is_expected.to be_listening }
    end
    describe port(9191) do
      it { is_expected.to be_listening }
    end
    # Neutron
    describe port(9696) do
      it { is_expected.to be_listening }
    end
    # Horizon
    describe port(80) do
      it { is_expected.to be_listening }
    end
    # RabbitMQ
    describe port(5672) do
      it { is_expected.to be_listening }
    end
    # Memcached
    describe port(11211) do
      it { is_expected.to be_listening }
    end


    # **************************************************************************
    # SERVICE TESTING
    # **************************************************************************

    # Nova
    describe service('nova-api') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-compute') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-cert') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-novncproxy') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-conductor') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-scheduler') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('nova-consoleauth') do
      it { should be_enabled }
      it { should be_running }
    end

    # Neutron
    describe service('neutron-dhcp-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-l3-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-lbaas-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-metadata-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-metering-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-openvswitch-agent') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-ovs-cleanup') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('neutron-server') do
      it { should be_enabled }
      it { should be_running }
    end

    # RabbitMQ
    describe service('rabbitmq-server') do
      it { should be_enabled }
      it { should be_running }
    end

    # Memcache
    describe service('memcached') do
      it { should be_enabled }
      it { should be_running }
    end

    # Libvirt
    describe service('libvirt-bin') do
      it { should be_enabled }
      it { should be_running }
    end

    # Qemu
    describe service('qemu-kvm') do
      it { should be_enabled }
      it { should be_running }
    end

    # OpenVSwitch
    describe service('openvswitch-switch') do
      it { should be_enabled }
      it { should be_running }
    end

    # Glance
    describe service('glance-api') do
      it { should be_enabled }
      it { should be_running }
    end
    describe service('glance-registry') do
      it { should be_enabled }
      it { should be_running }
    end

    # MySQL
    describe service('mysql') do
      it { should be_enabled }
      it { should be_running }
    end

    # Apache (for Horizon and Keystone)
    if os[:family] == 'ubuntu'
      describe service('apache2') do
        it { should be_enabled }
        it { should be_running }
      end
    end
    if os[:family] == 'centos' or os[:family] == 'redhat'
      describe service('httpd') do
        it { should be_enabled }
        it { should be_running }
      end
    end

  end
end
