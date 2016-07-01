require 'beaker-rspec'
require 'beaker/puppet_install_helper'
#run_puppet_install_helper
RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  modname = JSON.parse(open('metadata.json').read)['name'].split('-')[1]
  # Readable test descriptions
  c.formatter = :documentation
  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      # install git
      install_package host, 'git'
      zuul_ref = ENV['ZUUL_REF']
      zuul_branch = ENV['ZUUL_BRANCH']
      zuul_url = ENV['ZUUL_URL']
      repo = 'openstack/puppet-midonet'
      branch = ENV['PUPPET_MIDONET_BRANCH'] || "master"
      # Install dependent modules via git or zuul
      r = on host, "test -e /usr/zuul-env/bin/zuul-cloner", { :acceptable_exit_codes => [0,1] }
      if r.exit_code == 0
        zuul_clone_cmd = '/usr/zuul-env/bin/zuul-cloner '
        zuul_clone_cmd += '--cache-dir /opt/git '
        zuul_clone_cmd += "--zuul-ref #{zuul_ref} "
        zuul_clone_cmd += "--zuul-branch #{zuul_branch} "
        zuul_clone_cmd += "--zuul-url #{zuul_url} "
        zuul_clone_cmd += "git://git.openstack.org #{repo}"
        on host, zuul_clone_cmd
      else
        # For the future
        # on host, "git clone https://git.openstack.org/#{repo} #{repo}"
        rsync_to host, "#{proj_root}", "/tmp/#{modname}", opts={:silent => true}
      end
      # Install bundler and r10k to install modules from Puppetfile
      on host, "bash /tmp/#{modname}/spec/files/all-in-one.sh"
      on host, "gem install puppet --no-rdoc --no-ri --verbose"
      # Check what Puppet version are we using
      puppet_major_version = on(host, "puppet --version").stdout.split(".")[0]
      if puppet_major_version >= "4"
        puppet_module_dir = "/opt/puppetlabs/puppet/modules"
      elsif puppet_major_version == "3"
        puppet_module_dir = "/etc/puppet/modules"
      else
        raise "Your Puppet version is unsupported"
      end
      # Start out with clean moduledir, don't trust r10k to purge it
      on host, "rm -rf #{puppet_module_dir}/*"
      on host, "gem install bundler --no-rdoc --no-ri --verbose"
      on host, "gem install r10k --no-rdoc --no-ri --verbose"
      on host, "r10k puppetfile install --puppetfile /tmp/#{modname}/spec/files/Puppetfile -v debug --moduledir #{puppet_module_dir}"
      # Install the module being tested
      puppet_module_install(:source => proj_root, :module_name => modname, :target_module_path => puppet_module_dir)
      on host, "rm -fr /tmp/#{modname}"
      # List modules installed to help with debugging
      on host, "puppet module list", { :acceptable_exit_codes => 0 }
    end
  end
end
