require 'spec_helper_acceptance'

describe 'wsusserver_approvalrule' do
  context 'when creating an approval rule' do
    context 'with default parameters' do
      before(:all) do
        @approval_rule_name = 'Automatic Approval for Security Updates Rule'
      end
      let(:manifest) do
        <<-MANIFEST
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

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{@approval_rule_name}'' }).Count -eq 1") do
        its(:stdout) { is_expected.to match %r{true}i }
      end

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{@approval_rule_name}' }).Enabled") do
        its(:stdout) { is_expected.to match %r{true}i }
      end

      # Checking read-only properties have Something expected yet uncontrolled
      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{@approval_rule_name}' }).Id") do
        its(:stdout) { is_expected.to match %r{^[0-9]+$} }
      end
    end

    context 'with ensure => absent' do
      before(:all) do
        @approval_rule_name = 'Automatic Approval for Security Updates Rule'
      end
      let(:manifest) do
        <<-MANIFEST
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

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{@approval_rule_name}'' }).Count -eq 0") do
        its(:stdout) { is_expected.to match %r{true}i }
      end

    end

    context 'with enabled => false' do
      before(:all) do
        @approval_rule_name = 'Automatic Approval for Security Updates Rule'
      end
      let(:manifest) do
        <<-MANIFEST
            class { 'wsusserver':
              targeting_mode                            => 'Client',
              trigger_full_synchronization_post_install => false,
              products                                  => ['SQL Server'],
              update_languages                          => ['en'],
              update_classifications                    => ['Critical Updates', 'Security Updates'],
            }

            wsusserver_approvalrule { '#{@approval_rule_name}':
              ensure => 'present',
              enabled => false,
            }
          MANIFEST
      end

      after(:all) do
        resource('wsusserver_approvalrule', @approval_rule_name, ensure: 'absent')
      end

      it_behaves_like 'an idempotent resource'

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{@approval_rule_name}' }).Enabled") do
        its(:stdout) { is_expected.to match %r{false}i }
      end
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
  #           update_classifications                    => ['Critical Updates', 'Security Updates'],
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
