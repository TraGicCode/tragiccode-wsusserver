require 'spec_helper_acceptance'

describe 'wsusserver::computertargetgroup' do
  context 'when installing with provided mandatory parameters' do
    let(:manifest) do
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
    end

    it_behaves_like 'an idempotent resource'

    describe command('((Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "Services" }).Count -eq 1') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end

  context 'when uninstalling with provided mandatory parameters' do
    let(:manifest) do
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
    end

    it_behaves_like 'an idempotent resource'

    describe command('((Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "Services" }).Count -eq 0') do
      its(:stdout) { is_expected.to match %r{true}i }
    end
  end
end
