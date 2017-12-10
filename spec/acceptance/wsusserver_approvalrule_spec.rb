require 'spec_helper_acceptance'

describe 'wsusserver_approvalrule' do
  context 'when managing an approval rule' do
    context 'with default parameters' do
      before(:all) do
        @approval_rule_name = SecureRandom.hex(10)
        @manifest =  <<-MANIFEST
        class { 'wsusserver':
          targeting_mode                            => 'Client',
          trigger_full_synchronization_post_install => false,
          products                                  => ['SQL Server'],
          update_languages                          => ['en'],
          update_classifications                    => ['Critical Updates', 'Security Updates'],
        }

        wsusserver_approvalrule { '#{@approval_rule_name}':
          ensure => 'present',
        }
      MANIFEST
      end

      after(:all) do
        resource('wsusserver_approvalrule', @approval_rule_name, ensure: 'absent')
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'wsusserver_approvalrule', @approval_rule_name))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'present')
        puppet_resource_should_show('enabled', 'true')
        puppet_resource_should_show('rule_id', %r{\d+})
      end
    end
    context 'with ensure => absent' do
      before(:all) do
        @approval_rule_name = SecureRandom.hex(10)
        @manifest =  <<-MANIFEST
        class { 'wsusserver':
          targeting_mode                            => 'Client',
          trigger_full_synchronization_post_install => false,
          products                                  => ['SQL Server'],
          update_languages                          => ['en'],
          update_classifications                    => ['Critical Updates', 'Security Updates'],
        }

        wsusserver_approvalrule { '#{@approval_rule_name}':
          ensure => 'absent',
        }
      MANIFEST
      end

      it_behaves_like 'an idempotent resource'
      
      context 'when puppet resource is run' do
        before(:all) do
          @result = on(default, puppet('resource', 'wsusserver_approvalrule', @approval_rule_name))
        end

        include_context 'with a puppet resource run'
        puppet_resource_should_show('ensure', 'absent')
      end
    end
  end

  context 'with enabled => false' do
    before(:all) do
      @approval_rule_name = SecureRandom.hex(10)
      @manifest =  <<-MANIFEST
      class { 'wsusserver':
        targeting_mode                            => 'Client',
        trigger_full_synchronization_post_install => false,
        products                                  => ['SQL Server'],
        update_languages                          => ['en'],
        update_classifications                    => ['Critical Updates', 'Security Updates'],
      }

      wsusserver_approvalrule { '#{@approval_rule_name}':
        ensure  => 'present',
        enabled => false,
      }
    MANIFEST
    end

    it_behaves_like 'an idempotent resource'
    
    context 'when puppet resource is run' do
      before(:all) do
        @result = on(default, puppet('resource', 'wsusserver_approvalrule', @approval_rule_name))
      end

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'present')
      puppet_resource_should_show('enabled', 'false')
      puppet_resource_should_show('rule_id', %r{\d+})
    end
  end

  context 'with products => ["Windows Server 2016"]' do
    before(:all) do
      @approval_rule_name = SecureRandom.hex(10)
      @manifest =  <<-MANIFEST
      class { 'wsusserver':
        targeting_mode                            => 'Client',
        trigger_full_synchronization_post_install => false,
        products                                  => ['SQL Server'],
        update_languages                          => ['en'],
        update_classifications                    => ['Critical Updates', 'Security Updates'],
      }

      wsusserver_approvalrule { '#{@approval_rule_name}':
        ensure   => 'present',
        products => ['SQL Server'],
      }
    MANIFEST
    end

    it_behaves_like 'an idempotent resource'
    
    context 'when puppet resource is run' do
      before(:all) do
        @result = on(default, puppet('resource', 'wsusserver_approvalrule', @approval_rule_name))
      end

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'present')
      puppet_resource_should_show('enabled', 'true')
      puppet_resource_should_show('rule_id', %r{\d+})
      puppet_resource_should_show('products',  ['SQL Server'])
    end
  end

  # context 'when adding a classification to a rule' do
  #   let(:manifest) do
  #     <<-MANIFEST
  #         class { 'wsusserver':
  #           targeting_mode                            => 'Client',
  #           trigger_full_synchronization_post_install => false,
  #           products                                  => ['SQL Server'],
  #           update_languages                          => ['en'],
  #           update_classifications                     => ['Critical Updates', 'Security Updates'],
  #         }
  #         wsusserver::computertargetgroup { 'production':
  #           ensure => 'present',
  #         }
  #         wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
  #            ensure          => 'present',
  #            classifications => ['Critical Updates'],
  #            products        => ['SQL Server'],
  #            computer_groups => ['production']
  #         }
  #       MANIFEST
  #   end

  #   it_behaves_like 'an idempotent resource'

  #   describe command('((Get-WsusServer).GetInstallApprovalRules().GetUpdateClassifications() | Where-Object { $PSItem.Title -eq "Critical Updates" }).Count -eq 1') do
  #     its(:stdout) { is_expected.to match %r{true}i }
  #   end
  # end
end