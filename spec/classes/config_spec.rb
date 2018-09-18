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

    it {
      is_expected.to contain_exec('wsus-config-update-languages')
        .with(
          logoutput: true,
          provider: 'powershell',
        )
    }
  end
end
