class wsusserver(
  Array[String, 1] $update_languages,
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
  Optional[String] $proxy_server_name                = $wsusserver::params::proxy_server_name,
  Integer $proxy_server_port                         = $wsusserver::params::proxy_server_port,
  Boolean $allow_credentials_over_non_ssl            = $wsusserver::params::allow_credentials_over_non_ssl,
  Boolean $anonymousproxyaccess                      = $wsusserver::params::anonymousproxyaccess,
  Optional[String] $proxy_username                   = $wsusserver::params::proxy_username,
  Optional[String] $proxy_password                   = $wsusserver::params::proxy_password,
  Optional[String] $proxy_domain                     = $wsusserver::params::proxy_domain,  
  Enum['Server', 'Client'] $targeting_mode           = $wsusserver::params::targeting_mode,
  Boolean $host_binaries_on_microsoft_update         = $wsusserver::params::host_binaries_on_microsoft_update,
  Boolean $synchronize_automatically                 = $wsusserver::params::synchronize_automatically,
  String $synchronize_time_of_day                    = $wsusserver::params::synchronize_time_of_day,
  Integer $number_of_synchronizations_per_day        = $wsusserver::params::number_of_synchronizations_per_day,
  Boolean $send_sync_notification                    = $wsusserver::params::send_sync_notification,
  Array[String, 1] $sync_notification_recipients     = $wsusserver::params::sync_notification_recipients,
  Boolean $send_status_notification                  = $wsusserver::params::send_status_notification,
  Array[String, 1] $status_notification_recipients   = $wsusserver::params::status_notification_recipients,
  Enum['Weekly', 'Daily'] $notification_frequency    = $wsusserver::params::notification_frequency,
  String $notification_time_of_day                   = $wsusserver::params::notification_time_of_day,
  String $smtp_hostname                              = $wsusserver::params::smtp_hostname,
  Integer $smtp_port                                 = $wsusserver::params::smtp_port,
  Boolean $smtp_requires_authentication              = $wsusserver::params::smtp_requires_authentication,
  String $smtp_username                              = $wsusserver::params::smtp_username,
  String $smtp_password                              = $wsusserver::params::smtp_password,
  String $smtp_sender_displayname                    = $wsusserver::params::smtp_sender_displayname,
  String $smtp_sender_emailaddress                   = $wsusserver::params::smtp_sender_emailaddress,
  String $email_language                             = $wsusserver::params::email_language,
  Variant[ Enum['*'], Array[String] ] $products = [],
  Array[String] $product_families = [],
) inherits wsusserver::params {

  if $products == '*' and !(empty($product_families)) {
    fail('cannot provide a value for product_families when products is set to all (*).')
  }

  if empty($products) and empty($product_families) {
    fail('must provide a value for either products or product_families (or both).')
  }

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
    proxy_server_name                         => $proxy_server_name,
    proxy_server_port                         => $proxy_server_port,
    allow_credentials_over_non_ssl            => $allow_credentials_over_non_ssl,
    anonymousproxyaccess                      => $anonymousproxyaccess,
    proxy_username                            => $proxy_username,
    proxy_password                            => $proxy_password,
    proxy_domain                              => $proxy_domain,  
    update_languages                          => $update_languages,
    products                                  => $products,
    product_families                          => $product_families,
    update_classifications                    => $update_classifications,
    targeting_mode                            => $targeting_mode,
    host_binaries_on_microsoft_update         => $host_binaries_on_microsoft_update,
    synchronize_automatically                 => $synchronize_automatically,
    synchronize_time_of_day                   => $synchronize_time_of_day,
    number_of_synchronizations_per_day        => $number_of_synchronizations_per_day,
    trigger_full_synchronization_post_install => $trigger_full_synchronization_post_install,
    send_sync_notification                    => $send_sync_notification,
    sync_notification_recipients              => $sync_notification_recipients,
    send_status_notification                  => $send_status_notification,
    status_notification_recipients            => $status_notification_recipients,
    notification_frequency                    => $notification_frequency,
    notification_time_of_day                  => $notification_time_of_day,
    smtp_hostname                             => $smtp_hostname,
    smtp_port                                 => $smtp_port,
    smtp_requires_authentication              => $smtp_requires_authentication,
    smtp_username                             => $smtp_username,
    smtp_password                             => $smtp_password,
    smtp_sender_displayname                   => $smtp_sender_displayname,
    smtp_sender_emailaddress                  => $smtp_sender_emailaddress,
    email_language                            => $email_language,
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
