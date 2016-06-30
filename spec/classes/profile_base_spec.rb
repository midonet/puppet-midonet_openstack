require 'spec_helper'

describe 'midonet_openstack::profile::base' do
  it { is_expected.to contain_class('midonet_openstack') }
end
