require 'spec_helper_acceptance'

describe 'wsusserver::computertargetgroup' do

  context 'when installing with provided mandatory parameters' do

    let(:install_manifest) {
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'Services':
              ensure => 'present',
          }
        MANIFEST
    }

    it 'should run without errors' do
      apply_manifest(install_manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(install_manifest, :catch_changes => true)
    end

    describe command('((Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "Services" }).Count -eq 1') do
       its(:stdout) { should match /true/i }
    end

  end

  context 'when uninstalling with provided mandatory parameters' do

    let(:install_manifest) {
      <<-MANIFEST
          class { 'wsusserver':
            targeting_mode                            => 'Client',
            trigger_full_synchronization_post_install => false,
            products                                  => ['SQL Server'],
            update_languages                          => ['en'],
            update_classifications                    => ['Critical Updates', 'Security Updates'],
          }
          wsusserver::computertargetgroup { 'Services':
              ensure => 'absent',
          }
        MANIFEST
    }

    it 'should run without errors' do
      apply_manifest(install_manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(install_manifest, :catch_changes => true)
    end

    describe command('((Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "Services" }).Count -eq 0') do
       its(:stdout) { should match /true/i }
    end

  end
end