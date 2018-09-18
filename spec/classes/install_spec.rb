require 'spec_helper'

describe 'wsusserver::install' do
  context 'with default values for all parameters' do
    it { is_expected.to contain_class('wsusserver::install') }
    it { is_expected.to contain_class('wsusserver::params') }

    it {
      is_expected.to contain_dsc_windowsfeature('UpdateServices')
        .with(dsc_ensure: 'present',
              dsc_name: 'UpdateServices')
    }

    it {
      is_expected.to contain_dsc_windowsfeature('UpdateServices-UI')
        .with(dsc_ensure: 'present',
              dsc_name: 'UpdateServices-UI')
    }

    it {
      is_expected.to contain_exec('post install wsus content directory C:\WSUS')
        .with(
          refreshonly: true,
          timeout: 1200,
          provider: 'powershell',
        )
    }
  end

  context 'with package_ensure => absent' do
    let(:params) do
      {
        package_ensure: 'absent',
      }
    end

    it {
      is_expected.to contain_dsc_windowsfeature('UpdateServices')
        .with(dsc_ensure: 'absent',
              dsc_name: 'UpdateServices')
    }
    # TODO: I should uninstall this feature if the whole thing is getting uninstalled
    # it { should contain_dsc_windowsfeature('UpdateServices-UI').with({
    #     :dsc_ensure => 'absent',
    #     :dsc_name   => 'UpdateServices-UI',
    # })}
  end

  context 'with include_management_console => false' do
    let(:params) do
      {
        include_management_console: false,
      }
    end

    it {
      is_expected.to contain_dsc_windowsfeature('UpdateServices-UI')
        .with(dsc_ensure: 'absent',
              dsc_name: 'UpdateServices-UI')
    }
  end
end
