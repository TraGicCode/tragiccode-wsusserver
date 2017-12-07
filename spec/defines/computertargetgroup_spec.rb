require 'spec_helper'
describe 'wsusserver::computertargetgroup' do
  let(:title) {
    'production'
  }
  context 'with default values for all parameters' do
    let(:params) {{
      :ensure => 'present',
    }}
    it { should compile }
    it { should contain_exec('create-wsus-computertargetgroup-production').with({
      :command   => '$ErrorActionPreference = "Stop"
                          $(Get-WsusServer).CreateComputerTargetGroup("production")',
      :unless    => '$result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "production" }
                          if($result.Count -eq 1) {
                            Exit 0
                          }
                          Exit 1',
      :logoutput => true,
      :provider  => 'powershell',
    }) }
  end
  context 'with ensure => absent' do
    let(:params) {{
      :ensure => 'absent',
    }}
    it { should contain_exec('delete-wsus-computertargetgroup-production').with({
      :command   => '$ErrorActionPreference = "Stop"
                          $result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "production" }
                          $result.Delete()',
      :onlyif    => '$result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { $PSItem.Name -eq "production" }
                          if($result.Count -eq 1) {
                            Exit 0
                          }
                          Exit 1',
      :logoutput => true,
      :provider  => 'powershell',
    }) }
  end
end
