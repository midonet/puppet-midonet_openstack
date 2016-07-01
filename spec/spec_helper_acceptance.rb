require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(Dir.getwd))
  module_name = JSON.parse(open('metadata.json').read)['name'].split('-')[1]

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
    end
  end
end
