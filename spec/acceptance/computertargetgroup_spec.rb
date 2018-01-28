require 'spec_helper_acceptance'

describe 'wsusserver_computer_target_group' do
  context 'when managing an computer target group' do
    context 'with default parameters' do
      before(:all) do
        @computer_target_group_name = SecureRandom.hex(10)
        @manifest =  <<-MANIFEST
        class { 'wsusserver':
          targeting_mode                            => 'Client',
          trigger_full_synchronization_post_install => false,
          products                                  => ['SQL Server'],
          update_languages                          => ['en'],
          update_classifications                    => ['Critical Updates', 'Security Updates'],
        }

        wsusserver_computer_target_group { '#{@computer_target_group_name}':
          ensure => 'present',
        }
      MANIFEST
      end

      after(:all) do
        resource('wsusserver_computer_target_group', @computer_target_group_name, values: { ensure: 'absent' })
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('wsusserver_computer_target_group', @computer_target_group_name)
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'present')
        puppet_resource_should_show('id', %r{(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}})
      end
    end
    context 'with ensure => absent' do
      before(:all) do
        @computer_target_group_name = SecureRandom.hex(10)
        @manifest =  <<-MANIFEST
        class { 'wsusserver':
          targeting_mode                            => 'Client',
          trigger_full_synchronization_post_install => false,
          products                                  => ['SQL Server'],
          update_languages                          => ['en'],
          update_classifications                    => ['Critical Updates', 'Security Updates'],
        }

        wsusserver_computer_target_group { '#{@computer_target_group_name}':
          ensure => 'absent',
        }
      MANIFEST
      end

      it_behaves_like 'an idempotent resource'
      
      context 'when puppet resource is run' do
        before(:all) do
          @result = resource('wsusserver_computer_target_group', @computer_target_group_name)
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'absent')
      end
    end
  end
end