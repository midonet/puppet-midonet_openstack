require 'spec_helper_acceptance'

describe 'midonet_openstack class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should print out something' do
      pp = <<-EOS
        notice('Hello, is anybody out there?!')
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end
  end
end
