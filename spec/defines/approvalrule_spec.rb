# require 'spec_helper'
# describe 'wsusserver::approvalrule' do
#   let(:title) {
#     'production'
#   }
#   context 'with default values for all parameters' do
#     let(:params) {{
#       :ensure => 'present',
#     }}
#     it { should compile }
#     it { should contain_exec('create-wsus-approvalrule-production').with({
#       :logoutput => true,
#       :provider  => 'powershell',
#     }) }
#   end
#   context 'with ensure => absent' do
#     let(:params) {{
#       :ensure => 'absent',
#     }}
#     it { should contain_exec('delete-wsus-approvalrule-production').with({
#       :logoutput => true,
#       :provider  => 'powershell',
#     }) }
#   end
# end
