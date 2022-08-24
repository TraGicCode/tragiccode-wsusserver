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
    $proxy_server_name = ''
    $proxy_server_port = 80
    $allow_credentials_over_non_ssl = true
    $anonymousproxyaccess = true
    $proxy_username = ''
    $proxy_password = ''
    $proxy_domain = ''
    $update_languages = ['en']
    $targeting_mode = 'Client'
    $classifications = '*'
    $host_binaries_on_microsoft_update = false
    $synchronize_automatically = true
    $synchronize_time_of_day = '03:00:00' # midnight each day!
    $number_of_synchronizations_per_day = 1
    $send_sync_notification = false
    $sync_notification_recipients = ['']
    $send_status_notification = false
    $status_notification_recipients = ['']
    $notification_frequency = 'Weekly'
    $notification_time_of_day = '03:00:00'
    $smtp_hostname = ''
    $smtp_port = 25
    $smtp_requires_authentication = false
    $smtp_username = ''
    $smtp_password = ''
    $smtp_sender_displayname = ''
    $smtp_sender_emailaddress = ''
    $email_language = 'en'
}
