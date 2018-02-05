# Class: wsusserver::params
#
#
class wsusserver::params {
    $package_ensure = 'present'
    $include_management_console = true
    $trigger_full_synchronization_post_install = true
    $service_manage = true
    $service_ensure = 'running'
    $service_enable = true
    $wsus_directory = 'C:\\WSUS'
    $join_improvement_program = true
    $sync_from_microsoft_update = true
    $upstream_wsus_server_name = ''
    $upstream_wsus_server_port = 80
    $upstream_wsus_server_use_ssl = false
    $use_proxy = false
    $proxy_settings = {}
    $proxy_settings_defaults = {
      server_name                    => undef,
      server_port                    => 80,
      use_credentials                => false,
      allow_credentials_over_non_ssl => true,
      credentials                    => {
          username                   => undef,
          password                   => undef,
          domain                     => undef,
      }
    }
    $update_languages = ['en']
    $targeting_mode = 'Client'
    $classifications = '*'
    $host_binaries_on_microsoft_update = false
    $synchronize_automatically = true
    $synchronize_time_of_day = '03:00:00' # midnight each day!
    $number_of_synchronizations_per_day = 1
}
