require 'spec_helper'

input  = '127.0.0.0/24'
output = '127.0.0.3'

input2  = '172.17.0.0/24'
output2 = '172.17.0.8'

describe 'ip_for_network' do
  let :facts do
    {
      :interfaces                  => 'eth1,eth2',
      :ipaddress_eth1              => '127.0.0.3',
      :ipaddress_eth2              => '172.17.0.8',
    }
  end
  it { is_expected.to run.with_params(input).and_return(output) }
  it { is_expected.to run.with_params(input2).and_return(output2) }
end
