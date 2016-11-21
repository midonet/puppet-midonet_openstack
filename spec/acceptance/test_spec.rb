require 'spec_helper_acceptance'

describe 'midonet_openstack class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
      class {'::midonet_openstack::role::allinone':
        client_ip => '172.17.0.3',
        zk_id     => 1
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp, debug: true).exit_code).to_not eq(1)
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

    # Zookeeper
    describe port(2181) do
      it { is_expected.to be_listening }
    end

    # Cassandra
    describe port(9160) do
      it { is_expected.to be_listening }
    end

    describe port(7000) do
      it { is_expected.to be_listening }
    end

    describe port(7199) do
      it { is_expected.to be_listening }
    end

    describe port(9042) do
      it { is_expected.to be_listening }
    end


    # **************************************************************************
    # SERVICE TESTING
    # **************************************************************************

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

    describe service('neutron-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('rabbitmq-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('memcached') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('zookeeper') do
      it { should be_running }
    end

    describe service('cassandra') do
      it { should be_running }
    end

    if os[:family] == 'ubuntu'
      describe service('qemu-kvm') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('neutron-ovs-cleanup') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('libvirt-bin') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openvswitch-switch') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('apache2') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('mysql') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('glance-api') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('glance-registry') do
        it { should be_enabled }
        it { should be_running }
      end
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
      describe 'openstack horizon' do
        it 'should be available' do
          shell('source /etc/profile.d/openrc && curl -v http://172.17.0.3/horizon') do |r|
            expect(r.stderr).to match(/302/)
          end
        end
      end
    end

    if os[:family] == 'redhat'
      describe service('libvirtd') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openvswitch') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('httpd') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('mariadb') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-glance-api') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-glance-registry') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-api') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-compute') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-cert') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-novncproxy') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-conductor') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-scheduler') do
        it { should be_enabled }
        it { should be_running }
      end
      describe service('openstack-nova-consoleauth') do
        it { should be_enabled }
        it { should be_running }
      end
    describe 'openstack horizon' do
      it 'should be available' do
        shell('source /etc/profile.d/openrc && curl -v http://172.17.0.3/dashboard') do |r|
          expect(r.stderr).to match(/302/)
        end
      end
    end
    end

    # **************************************************************************
    # OPENSTACK TESTING
    # **************************************************************************

    describe 'openstack keystone' do
      it 'should issue a token' do
        shell('source /etc/profile.d/openrc && openstack token issue') do |r|
          expect(r.stdout).to match(/expires/)
        end
      end
    end

    describe 'openstack glance' do
      it 'should connect to DB' do
        shell('source /etc/profile.d/openrc && glance image-list') do |r|
          expect(r.stdout).to match(/Name/)
        end
      end
    end

    describe 'openstack nova' do
      it 'should connect to DB' do
        shell('source /etc/profile.d/openrc && nova service-list') do |r|
          expect(r.stdout).not_to match(/nova.*down/)
        end
      end

      it 'should connect to glance from nova' do
        shell('source /etc/profile.d/openrc && nova image-list') do |r|
          expect(r.stdout).to match(/Status/)
        end
      end
    end

    describe 'openstack nova endpoints' do
      it 'should have the endpoints on' do
        shell('source /etc/profile.d/openrc && nova endpoints') do |r|
          expect(r.stdout).to match(/Value/)
        end
      end
    end

    describe 'openstack neutron' do
      it 'should launch neutron-server' do
        shell('source /etc/profile.d/openrc && neutron ext-list') do |r|
          expect(r.stdout).to match(/name/)
        end
      end

      it 'should not have any agent down' do
        shell('source /etc/profile.d/openrc && neutron agent-list') do |r|
          expect(r.stdout).not_to match(/:-\(/)
        end
      end
    end


  end
end
