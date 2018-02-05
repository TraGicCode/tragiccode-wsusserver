class wsusserver(
  Array[String, 1] $update_languages,
  Array[String, 1] $products,
  Array[String, 1] $update_classifications,
  Enum['present', 'absent'] $package_ensure          = $wsusserver::params::package_ensure,
  Boolean $include_management_console                = $wsusserver::params::include_management_console,
  Boolean $trigger_full_synchronization_post_install = $wsusserver::params::trigger_full_synchronization_post_install,
  Boolean $service_manage                            = $wsusserver::params::service_manage,
  Enum['running', 'stopped'] $service_ensure         = $wsusserver::params::service_ensure,
  Variant[ Boolean, Enum['manual'] ] $service_enable = $wsusserver::params::service_enable,
  Stdlib::Absolutepath $wsus_directory               = $wsusserver::params::wsus_directory,
  Boolean $join_improvement_program                  = $wsusserver::params::join_improvement_program,
  Boolean $sync_from_microsoft_update                = $wsusserver::params::sync_from_microsoft_update,
  Optional[String] $upstream_wsus_server_name        = $wsusserver::params::upstream_wsus_server_name,
  Integer $upstream_wsus_server_port                 = $wsusserver::params::upstream_wsus_server_port,
  Boolean $upstream_wsus_server_use_ssl              = $wsusserver::params::upstream_wsus_server_use_ssl,
  Boolean $use_proxy                                 = $wsusserver::params::use_proxy,
  Hash $proxy_settings                               = $wsusserver::params::proxy_settings,
  Enum['Server', 'Client'] $targeting_mode           = $wsusserver::params::targeting_mode,
  Boolean $host_binaries_on_microsoft_update         = $wsusserver::params::host_binaries_on_microsoft_update,
  Boolean $synchronize_automatically                 = $wsusserver::params::synchronize_automatically,
  String $synchronize_time_of_day                    = $wsusserver::params::synchronize_time_of_day,
  Integer $number_of_synchronizations_per_day        = $wsusserver::params::number_of_synchronizations_per_day,
) inherits wsusserver::params {

  class { 'wsusserver::install':
    package_ensure             => $package_ensure,
    wsus_directory             => $wsus_directory,
    include_management_console => $include_management_console,
    join_improvement_program   => $join_improvement_program,
  }

  class { 'wsusserver::config':
    join_improvement_program                  => $join_improvement_program,
    sync_from_microsoft_update                => $sync_from_microsoft_update,
    upstream_wsus_server_name                 => $upstream_wsus_server_name,
    upstream_wsus_server_port                 => $upstream_wsus_server_port,
    upstream_wsus_server_use_ssl              => $upstream_wsus_server_use_ssl,
    use_proxy                                 => $use_proxy,
    proxy_settings                            => $proxy_settings,
    update_languages                          => $update_languages,
    products                                  => $products,
    update_classifications                    => $update_classifications,
    targeting_mode                            => $targeting_mode,
    host_binaries_on_microsoft_update         => $host_binaries_on_microsoft_update,
    synchronize_automatically                 => $synchronize_automatically,
    synchronize_time_of_day                   => $synchronize_time_of_day,
    number_of_synchronizations_per_day        => $number_of_synchronizations_per_day,
    trigger_full_synchronization_post_install => $trigger_full_synchronization_post_install,
  }

  class { 'wsusserver::service':
    service_manage => $service_manage,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }

  include wsusserver::built_in_computer_target_groups

  Class['wsusserver::install']
  -> Class['wsusserver::config']
  -> Class['wsusserver::service']

  Class['wsusserver::install']
  -> Class['wsusserver::built_in_computer_target_groups']
}
