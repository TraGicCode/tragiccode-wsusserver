require 'spec_helper_acceptance'

describe 'wsusserver::approvalrule' do
  context 'when installing with provided mandatory parameters' do
    let(:install_manifest) do
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'production':
              ensure => 'present',
          }
          wsusserver::approvalrule { 'Default Automatic Approval Rule':
              ensure          => 'absent',
              classifications => ['Critical Updates'],
              products        => ['SQL Server'],
              computer_groups => ['production']
          }
          wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
              ensure          => 'present',
              classifications => ['Critical Updates'],
              products        => ['SQL Server'],
              computer_groups => ['production']
          }
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Count -eq 1') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end

  context 'when uninstalling with provided mandatory parameters' do
    let(:install_manifest) do
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'production':
            ensure => 'present',
          }
          wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
               ensure          => 'absent',
               classifications => ['Critical Updates'],
               products        => ['SQL Server'],
               computer_groups => ['production']
          }
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Count -eq 0') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end

  context 'when disabling a rule' do
    let(:install_manifest) do
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'production':
            ensure => 'present',
          }
          wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
              ensure          => 'present',
              enabled         => false,
              classifications => ['Critical Updates'],
              products        => ['SQL Server'],
              computer_groups => ['production']
          }
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Enabled') do
      its(:stdout) { is_expected.to match %r{false}i }
    end
  end

  context 'when enabling a rule' do
    let(:install_manifest) do
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'production':
            ensure => 'present',
          }
          wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
             ensure          => 'present',
             classifications => ['Critical Updates'],
             products        => ['SQL Server'],
             computer_groups => ['production']
          }
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe command('((Get-WsusServer).GetInstallApprovalRules() | Where-Object { $PSItem.Name -eq "Automatic Approval for Security Updates Rule" }).Enabled') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end

  context 'when adding a classification to a rule' do
    let(:install_manifest) do
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'production':
            ensure => 'present',
          }
          wsusserver::approvalrule { 'Automatic Approval for Security Updates Rule':
             ensure          => 'present',
             classifications => ['Critical Updates'],
             products        => ['SQL Server'],
             computer_groups => ['production']
          }
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe command('((Get-WsusServer).GetInstallApprovalRules().GetUpdateClassifications() | Where-Object { $PSItem.Title -eq "Critical Updates" }).Count -eq 1') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end
end
