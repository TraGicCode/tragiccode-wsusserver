require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

# automatically load any shared examples or contexts
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

run_puppet_install_helper
install_module
install_module_dependencies

# Install additional modules for soft deps
# install_module_from_forge('puppetlabs-java', '>= 2.1.0 < 3.0.0')
# install_module_from_forge('puppetlabs-apt', '>= 4.1.0 < 5.0.0')

RSpec.configure do |c|
  c.formatter = :documentation
end
