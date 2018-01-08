require 'spec_helper'
describe 'wsusserver' do
  context 'with default values for all parameters' do
    update_languages = ['en']
    products = ['Windows Server 2016']
    update_classifications = ['Critical Updates']
    let(:params) {{
      :update_languages       => update_languages,
      :products               => products,
      :update_classifications => update_classifications,
    }}

    it { should contain_class('wsusserver') }
    it { should contain_class('wsusserver::install').with({
      :package_ensure             => 'present',
      :wsus_directory             => 'C:\\WSUS',
      :include_management_console => true,
      :join_improvement_program   => true,
    }) }

    it { should contain_class('wsusserver::config').with({
      :join_improvement_program => true,
      :sync_from_microsoft_update => true,
      :upstream_wsus_server_name => '',
      :upstream_wsus_server_port => 80,
      :upstream_wsus_server_use_ssl => false,
      :update_languages => ['en'],
      :products                                  => products,
      :update_classifications                    => update_classifications,
      :targeting_mode                            => 'Client',
      :host_binaries_on_microsoft_update         => false,
      :synchronize_automatically                 => true,
      :synchronize_time_of_day                   => '03:00:00',
      :number_of_synchronizations_per_day        => 1,
      :trigger_full_synchronization_post_install => true,
    }) }

    it { should contain_class('wsusserver::config').that_requires('Class[wsusserver::install]').that_comes_before('Class[wsusserver::service]') }
    it { should contain_class('wsusserver::built_in_computer_target_groups').that_requires('Class[wsusserver::install]') }
  end
end
