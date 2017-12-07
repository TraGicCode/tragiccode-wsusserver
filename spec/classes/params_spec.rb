require 'spec_helper'
describe 'wsusserver::params' do
  context 'with default values for all parameters' do

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_resource_count(0) }
  end
end
