require 'spec_helper'

describe 'wsusserver::built_in_computer_target_groups' do
  context 'with default values for all parameters' do
    ['Unassigned Computers'].each do |built_in_computer_target_group|
      it {
        is_expected.to contain_wsusserver_computer_target_group(built_in_computer_target_group).with(ensure: 'present')
      }
    end
  end
end
