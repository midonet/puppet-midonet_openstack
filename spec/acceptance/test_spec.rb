require 'spec_helper_acceptance'

describe 'midonet_openstack class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should print out something' do
      pp = <<-EOS
        include ::midonet_openstack::role::allinone
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe port(5000) do
      it { is_expected.to be_listening }
    end

  end
end
