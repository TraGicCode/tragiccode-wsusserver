require 'spec_helper'

describe 'wsusserver::install' do
  context 'with default values for all parameters' do
    it { should contain_class('wsusserver::install') }
    it { should contain_class('wsusserver::params') }

    it { should contain_dsc_windowsfeature('UpdateServices').with({
        :dsc_ensure => 'present',
        :dsc_name   => 'UpdateServices',
    }) }

    it { should contain_dsc_windowsfeature('UpdateServices-UI').with({
        :dsc_ensure => 'present',
        :dsc_name   => 'UpdateServices-UI',
    })}

    it { should contain_exec('post install wsus content directory C:\WSUS').with({
      :command     => 'if (!(Test-Path -Path $env:TMP)) {
                      New-Item -Path $env:TMP -ItemType Directory
                    }
                    & \'C:\\Program Files\\Update Services\\Tools\\WsusUtil.exe\' PostInstall CONTENT_DIR="C:\\WSUS" MU_ROLLUP=1
                    if ($LASTEXITCODE -eq 1) { 
                      Exit 1 
                    } 
                    else { 
                      Exit 0 
                    }',
      :logoutput   => true,
      :refreshonly => true,
      :timeout     => 1200,
      :provider    => 'powershell',
    })}
  end

  context 'with package_ensure => absent' do
    let(:params) {{
      :package_ensure => 'absent',
    }}
    it { should contain_dsc_windowsfeature('UpdateServices').with({
        :dsc_ensure => 'absent',
        :dsc_name   => 'UpdateServices',
    })}
    # TODO: I should uninstall this feature if the whole thing is getting uninstalled
    # it { should contain_dsc_windowsfeature('UpdateServices-UI').with({
    #     :dsc_ensure => 'absent',
    #     :dsc_name   => 'UpdateServices-UI',
    # })}
  end

  context 'with include_management_console => false' do
    let(:params) {{
      :include_management_console => false,
    }}
    it { should contain_dsc_windowsfeature('UpdateServices-UI').with({
        :dsc_ensure => 'absent',
        :dsc_name   => 'UpdateServices-UI',
    })}
  end
end