require 'spec_helper'
describe 'wsusserver::config' do
  context 'with default values for all parameters' do
    let(:params) do
      {
        update_languages: ['en'],
        products: ['Windows Server 2016'],
        update_classifications: ['Critical Updates'],
      }
    end

    it { is_expected.to contain_class('wsusserver::config') }
    it { is_expected.to contain_class('wsusserver::params') }

    it {
      is_expected.to contain_exec('wsus-config-update-synchronization')
        .with(
          logoutput: true,
          provider: 'powershell',
        )
    }

    it { should contain_exec('wsus-config-update-synchronization').with({
      :command   => '$ErrorActionPreference = "Stop"
                    $wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    $wsusConfiguration.SyncFromMicrosoftUpdate=$true
                    if ($true -eq $false) {
                      $wsusConfiguration.UpstreamWsusServerName = ""
                      $wsusConfiguration.UpstreamWsusServerPortNumber = 80
                      $wsusConfiguration.UpstreamWsusServerUseSsl = $false
                    }
                    $wsusConfiguration.Save()
                    While ($wsusConfiguration.GetUpdateServerConfigurationState() -eq \'ProcessingSave\') {
                      Write-Output "." -NoNewline
                      Start-Sleep -Seconds 5
                    }',
      :unless    => '$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if ($wsusConfiguration.SyncFromMicrosoftUpdate -eq $true) {
                      Exit 0
                    }
                    Exit 1',
      :logoutput => true,
      :provider  => 'powershell',
    }) }
    # exit 1 = do something
    # exit 0 = do nothing
    #With defaults - do not config proxy 
    it { should contain_exec('wsus-config-disable-proxy').with({
      :command    => '$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                      $wsusConfiguration.UseProxy = $false
                      $wsusConfiguration.Save()',
      :unless     => '$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                      if ($wsusConfiguration.UseProxy -eq $false) {
                        Exit 0
                      }
                      Exit 1',
      :logoutput  => true,
      :provider   => 'powershell',
    }) }


    it { should contain_exec('wsus-config-update-languages').with({
      :command   => '$ErrorActionPreference = "Stop"
                    $wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    $wsusConfiguration.AllUpdateLanguagesEnabled = $false
                    $wsusConfiguration.AllUpdateLanguagesDssEnabled = $false
                    $wsusConfiguration.SetEnabledUpdateLanguages("en" -split ",")
                    $wsusConfiguration.Save()
                    While ($wsusConfiguration.GetUpdateServerConfigurationState() -eq \'ProcessingSave\') {
                      Write-Output "." -NoNewline
                      Start-Sleep -Seconds 5
                    }',
      :unless    => '$wsusServerConfig = (Get-WsusServer).GetConfiguration()
                    $currentEnabledLanguages = $wsusServerConfig.GetEnabledUpdateLanguages()
                    $compareResult = Compare-Object -ReferenceObject $currentEnabledLanguages -DifferenceObject ("en").Split(",")
                    if($compareResult -eq $null)
                    {
                        # no differences
                        Exit 0
                    }
                    else
                    {
                        # differences
                        Exit 1
                    }',
      :logoutput => true,
      :provider  => 'powershell',
    }) }

  end
end
