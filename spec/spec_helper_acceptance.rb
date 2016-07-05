require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(Dir.getwd))
  module_name = JSON.parse(open('metadata.json').read)['name'].split('-')[1]
  module_full_name = JSON.parse(open('metadata.json').read)['name']
  module_version = JSON.parse(open('metadata.json').read)['version']

  # Make sure proj_root is the real project root
  unless File.exists?("#{proj_root}/metadata.json")
    raise "bundle exec rspec spec/acceptance needs be run from module root."
  end

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      # install git
      install_package host, 'git'

      # Check what Puppet version are we using
      puppet_major_version = on(host, "puppet --version").stdout.split(".")[0]
      if puppet_major_version >= "4"
        puppet_module_dir = "/opt/puppetlabs/puppet/modules"
      elsif puppet_major_version == "3"
        puppet_module_dir = "/etc/puppet/modules"
      else
        raise "Your Puppet version is unsupported"
      end


      on host, "rm -rf #{puppet_module_dir}/*"
      on host, "cd /tmp/ && git clone https://github.com/midonet/puppet-midonet_openstack.git"
      on host, "bash -x /tmp/puppet-#{module_name}/spec/files/all-in-one.sh"
      on host, "cd /tmp/puppet-#{module_name} && puppet module build"
      on host, "gem install bundler --no-rdoc --no-ri --verbose"
      on host, "gem install r10k --no-rdoc --no-ri --verbose"
      on host, "r10k puppetfile install --puppetfile /tmp/puppet-#{module_name}/Puppetfile -v debug --moduledir #{puppet_module_dir}"
      on host, "cd /tmp/puppet-midonet_openstack/pkg && puppet module install #{module_full_name}-#{module_version}.tar.gz"
      # List modules installed to help with debugging
      on host, "puppet module list"
      on host, "rm -rf /tmp/*"
      #Cleanup!
    end
  end
end
