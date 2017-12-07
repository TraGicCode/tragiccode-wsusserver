require 'spec_helper'
describe 'wsusserver::computertargetgroup' do
  let(:title) do
    'production'
  end

  context 'with default values for all parameters' do
    let(:params) do
      {
        ensure: 'present',
      }
    end

    it { is_expected.to compile }
    it {
      is_expected.to contain_exec('create-wsus-computertargetgroup-production').with(logoutput: true,
                                                                                     provider: 'powershell')
    }
  end
  context 'with ensure => absent' do
    let(:params) do
      {
        ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_exec('delete-wsus-computertargetgroup-production').with(logoutput: true,
                                                                                     provider: 'powershell')
    }
  end
end
