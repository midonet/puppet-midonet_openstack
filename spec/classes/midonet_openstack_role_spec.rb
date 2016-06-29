require 'spec_helper'

describe 'midonet_openstack::role' do
  it { is_expected.to contain_class('midonet_openstack::profile::base') }
end
