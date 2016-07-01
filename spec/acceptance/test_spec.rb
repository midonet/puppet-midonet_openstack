require 'spec_helper_acceptance'

describe 'test description' do
  context 'test context' do
    pp = <<-EOS
      notice("Hello, world!")
    EOS

    apply_manifest(pp)
  end
end
