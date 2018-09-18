require 'spec_helper_acceptance'

describe 'wsusserver' do
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
        MANIFEST
    end

    it 'runs without errors' do
      apply_manifest(install_manifest, catch_failures: true)
    end

    it 'is idempotent' do
      apply_manifest(install_manifest, catch_changes: true)
    end

    describe windows_feature('UpdateServices') do
      it { is_expected.to be_installed }
    end

    describe windows_feature('UpdateServices-UI') do
      it { is_expected.to be_installed }
    end

    describe file('C:/WSUS') do
      it { is_expected.to be_directory }
    end

    describe port(8530) do
      it { is_expected.to be_listening }
    end

    describe command('(Get-WsusServer).GetConfiguration().OobeInitialized') do
      its(:stdout) { is_expected.to match %r{true}i }
    end

    describe command('(Get-WsusServer).GetConfiguration().MURollupOptin') do
      its(:stdout) { is_expected.to match %r{true}i }
    end

    describe command('(Get-WsusServer).GetConfiguration().SyncFromMicrosoftUpdate') do
      its(:stdout) { is_expected.to match %r{true}i }
    end

    describe command('(Get-WsusServer).GetConfiguration().GetEnabledUpdateLanguages()') do
      its(:stdout) { is_expected.to match %r{en}i }
    end

    describe command('(Get-WsusServer).GetConfiguration().TargetingMode') do
      its(:stdout) { is_expected.to match %r{client}i }
    end

    describe command('(Get-WsusServer).GetConfiguration().HostBinariesOnMicrosoftUpdate') do
      its(:stdout) { is_expected.to match %r{false}i }
    end
  end
end
