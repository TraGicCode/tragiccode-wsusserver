require 'spec_helper_acceptance'

describe 'wsusserver_approvalrule' do
  context 'when creating an approval rule' do
    context 'with default parameters' do
      let(:approval_rule_name) { 'Automatic Approval for Security Updates Rule' }
      let(:manifest) do
        <<-MANIFEST
            class { 'wsusserver':
              targeting_mode                            => 'Client',
              trigger_full_synchronization_post_install => false,
              products                                  => ['SQL Server'],
              update_languages                          => ['en'],
              update_classifications                    => ['Critical Updates', 'Security Updates'],
            }

            wsusserver_approvalrule { '#{approval_rule_name}':
              ensure => 'present',
            }
          MANIFEST
      end

      after(:all) do
        resource('wsusserver_approvalrule', approval_rule_name, ensure: 'absent')
      end

      it_behaves_like 'an idempotent resource'

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{approval_rule_name}'' }).Count -eq 1") do
        its(:stdout) { is_expected.to match %r{true}i }
      end

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{approval_rule_name}' }).Enabled") do
        its(:stdout) { is_expected.to match %r{true}i }
      end
    end

    context 'with ensure => absent' do
      let(:approval_rule_name) { 'Automatic Approval for Security Updates Rule' }
      let(:manifest) do
        <<-MANIFEST
            class { 'wsusserver':
              targeting_mode                            => 'Client',
              trigger_full_synchronization_post_install => false,
              products                                  => ['SQL Server'],
              update_languages                          => ['en'],
              update_classifications                    => ['Critical Updates', 'Security Updates'],
            }

            wsusserver_approvalrule { '#{approval_rule_name}':
              ensure => 'absent',
            }
          MANIFEST
      end

      it_behaves_like 'an idempotent resource'

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{approval_rule_name}'' }).Count -eq 0") do
        its(:stdout) { is_expected.to match %r{true}i }
      end

    end

    context 'with enabled => false' do
      let(:approval_rule_name) { 'Automatic Approval for Security Updates Rule' }
      let(:manifest) do
        <<-MANIFEST
            class { 'wsusserver':
              targeting_mode                            => 'Client',
              trigger_full_synchronization_post_install => false,
              products                                  => ['SQL Server'],
              update_languages                          => ['en'],
              update_classifications                    => ['Critical Updates', 'Security Updates'],
            }

            wsusserver_approvalrule { '#{approval_rule_name}':
              ensure => 'present',
              enabled => false,
            }
          MANIFEST
      end

      after(:all) do
        resource('wsusserver_approvalrule', approval_rule_name, ensure: 'absent')
      end

      it_behaves_like 'an idempotent resource'

      describe command("((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq '#{approval_rule_name}' }).Enabled") do
        its(:stdout) { is_expected.to match %r{false}i }
      end
    end

  end

  # context 'when uninstalling with provided mandatory parameters' do
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
  #              ensure          => 'absent',
  #              classifications => ['Critical Updates'],
  #              products        => ['SQL Server'],
  #              computer_groups => ['production']
  #         }
  #       MANIFEST
  #   end

  #   it_behaves_like 'an idempotent resource'

  #   describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Count -eq 0') do
  #     its(:stdout) { is_expected.to match %r{true}i }
  #   end
  # end

  # context 'when disabling a rule' do
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
  #             ensure          => 'present',
  #             enabled         => false,
  #             classifications => ['Critical Updates'],
  #             products        => ['SQL Server'],
  #             computer_groups => ['production']
  #         }
  #       MANIFEST
  #   end

  #   it_behaves_like 'an idempotent resource'

  #   describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Enabled') do
  #     its(:stdout) { is_expected.to match %r{false}i }
  #   end
  # end

  # context 'when enabling a rule' do
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

  #   describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Enabled') do
  #     its(:stdout) { is_expected.to match %r{true}i }
  #   end
  # end

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
