require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
install_module
install_module_dependencies

# Install additional modules for soft deps
# install_module_from_forge('puppetlabs-java', '>= 2.1.0 < 3.0.0')
# install_module_from_forge('puppetlabs-apt', '>= 4.1.0 < 5.0.0')

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation
end
