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

  end
end
