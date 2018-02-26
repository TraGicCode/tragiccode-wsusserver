# Class: wsusserver::config
#
#
class wsusserver::config(
  Array[String, 1] $update_languages,
  Array[String, 1] $products,
  Array[String, 1] $update_classifications,
  Boolean $join_improvement_program                  = $wsusserver::params::join_improvement_program,
  Boolean $sync_from_microsoft_update                = $wsusserver::params::sync_from_microsoft_update,
  Optional[String] $upstream_wsus_server_name        = $wsusserver::params::upstream_wsus_server_name,
  Integer $upstream_wsus_server_port                 = $wsusserver::params::upstream_wsus_server_port,
  Boolean $upstream_wsus_server_use_ssl              = $wsusserver::params::upstream_wsus_server_use_ssl,
  Enum['Server', 'Client'] $targeting_mode           = $wsusserver::params::targeting_mode,
  Boolean $host_binaries_on_microsoft_update         = $wsusserver::params::host_binaries_on_microsoft_update,
  Boolean $synchronize_automatically                 = $wsusserver::params::synchronize_automatically,
  String $synchronize_time_of_day                    = $wsusserver::params::synchronize_time_of_day,
  Integer $number_of_synchronizations_per_day        = $wsusserver::params::number_of_synchronizations_per_day,
  Boolean $trigger_full_synchronization_post_install = $wsusserver::params::trigger_full_synchronization_post_install,
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
) inherits wsusserver::params {

    exec { 'wsus-config-update-join-improvement-program':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.MURollupOptin=\$${join_improvement_program}
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if (\$wsusConfiguration.MURollupOptin -eq \$${join_improvement_program}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }


    if ($send_sync_notification or $send_status_notification) {
      # Ensure SMTP Hostname is set if needed
      if ($smtp_hostname == undef or empty($smtp_hostname)) {
        fail('must define smtp_hostname to send sync or status notifications')
      }
      # Alter smtp_hostname if needed
      exec { 'wsus-config-set-smtp-hostname':
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      write-output \"Setting SmtpHostname to ${smtp_hostname}\"
                      \$wsusEmailNotificationConfiguration.SmtpHostName = \"${smtp_hostname}\"
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      if (\$wsusEmailNotificationConfiguration.SmtpHostName -eq \"${smtp_hostname}\") {
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }
      # Alter sender information if needed
      exec { 'wsus-config-set-smtp-sender-info':
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      write-output \"Setting SenderDisplayName to ${smtp_sender_displayname}\"
                      \$wsusEmailNotificationConfiguration.SenderDisplayName = \"${smtp_sender_displayname}\"
                      write-output \"Setting SenderEmailAddress to ${smtp_sender_emailaddress}\"
                      \$wsusEmailNotificationConfiguration.SenderEmailAddress = \"${smtp_sender_emailaddress}\"
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      if ((\$wsusEmailNotificationConfiguration.SenderDisplayName -eq \"${smtp_sender_displayname}\") -and (\$wsusEmailNotificationConfiguration.SenderEmailAddress.toString() -eq \"${smtp_sender_emailaddress}\")) {
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }
      #Update EmailLanguage if needed
      # Default to english 
      if ($email_language == undef or empty($email_language)) {
        $email_language = 'en'
      }

      exec { 'wsus-config-set-email-language':
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      write-output \"Setting EmailLanguage to ${email_language}\"
                      \$wsusEmailNotificationConfiguration.EmailLanguage = \"${email_language}\"
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      if (\$wsusEmailNotificationConfiguration.EmailLanguage -eq \"${email_language}\") {
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }

    }

    # Sync Notification Settings
    exec { 'wsus-config-sync-notification-settings':
      #Set sync to true or false
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailNotificationConfiguration.SendSyncNotification = \$${send_sync_notification}
                    \$wsusEmailNotificationConfiguration.Save()
                    return 'SendSyncNotification setting updated'
                   ",
      unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    if (\$wsusEmailNotificationConfiguration.SendSyncNotification -eq \$${send_sync_notification}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }


    # Status Report Notification Settings
    exec { 'wsus-config-status-report-notification-settings':
      #Set sync to true or false
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailNotificationConfiguration.SendStatusNotification = \$${send_status_notification}
                    \$wsusEmailNotificationConfiguration.Save()
                    return 'SendStatusNotification setting updated'
                   ",
      unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    if (\$wsusEmailNotificationConfiguration.SendStatusNotification -eq \$${send_status_notification}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }


    # Sync Notification Recipients
    $sync_recipients = join($sync_notification_recipients, ', ')
    exec { 'wsus-config-sync-notification-recipients':
      #Set recip to correct list
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailRecipients = \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.toString() 
                    write-output \"Updating recipients from: \$wsusEmailRecipients to: ${sync_recipients}\"
                    #Clear recipient list
                    \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.Clear()
                    #Add all recipients
                    foreach (\$recip in \"${sync_recipients}\".split(',')) {
                       \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.Add(\$recip)
                    }
                    #Save
                    \$wsusEmailNotificationConfiguration.Save()
                   ",
      unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailSyncNotificationRecipients = \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.toString()
                    if (\$wsusEmailNotificationConfiguration.SendSyncNotification -eq \$false) {
                      #Can't change recipients if sendsyncnotification is false
                      Exit 0
                    }
                    if (\$wsusEmailSyncNotificationRecipients -eq \"${sync_recipients}\") {
                      #Recipient list is correct
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }

    if ($send_status_notification) {
      # Status Report Notification Recipients
      $status_recipients = join($status_notification_recipients, ', ')
      exec { 'wsus-config-status-notification-recipients':
        #Set recip to correct list
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      \$wsusEmailRecipients = \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.toString() 
                      write-output \"Updating recipients from: \$wsusEmailRecipients to: ${status_recipients}\"
                      #Clear recipient list
                      \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.Clear()
                      #Add all recipients
                      foreach (\$recip in \"${status_recipients}\".split(',')) {
                         \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.Add(\$recip)
                      }
                      #Save
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      \$wsusEmailStatusNotificationRecipients = \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.toString()
                      if (\$wsusEmailStatusNotificationRecipients -eq \"${status_recipients}\") {
                        #Recipient list is correct
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }

      # Status Report Notification Frequency
      exec { 'wsus-config-status-report-frequency':
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      write-output \"Setting StatusNotificationFrequency to ${notification_frequency}\"
                      \$wsusEmailNotificationConfiguration.StatusNotificationFrequency = \"${notification_frequency}\"
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      if (\$wsusEmailNotificationConfiguration.StatusNotificationFrequency -eq \"${notification_frequency}\") {
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }

      # Status Report Notification TimeofDay
      exec { 'wsus-config-status-report-timeofday':
        command   => "\$ErrorActionPreference = \"Stop\"
                      \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      write-output \"Setting StatusNotificationTimeOfDay to ${notification_time_of_day}\"
                      \$wsusEmailNotificationConfiguration.StatusNotificationTimeOfDay = \"${notification_time_of_day}\"
                      \$wsusEmailNotificationConfiguration.Save()
                     ",
        unless    => "\$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                      if (\$wsusEmailNotificationConfiguration.StatusNotificationTimeOfDay -eq \"${notification_time_of_day}\") {
                        Exit 0
                      }
                      Exit 1",
        logoutput => true,
        provider  => 'powershell',
      }

    }

    # TODO: Implement idempotence check for upstream server.  currently i just execute this is sync from microsoft
    #       flag changes
    # Gets or sets whether update binaries are downloaded from Microsoft Update or from the upstream server.
    exec { 'wsus-config-update-synchronization':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.SyncFromMicrosoftUpdate=\$${sync_from_microsoft_update}
                    if (\$${sync_from_microsoft_update} -eq \$false) {
                      \$wsusConfiguration.UpstreamWsusServerName = \"${upstream_wsus_server_name}\"
                      \$wsusConfiguration.UpstreamWsusServerPortNumber = ${upstream_wsus_server_port}
                      \$wsusConfiguration.UpstreamWsusServerUseSsl = \$${upstream_wsus_server_use_ssl}
                    }
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if (\$wsusConfiguration.SyncFromMicrosoftUpdate -eq \$${sync_from_microsoft_update}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }
    # TODO: 
    # 1.) handle * for all languages instead of having to explicitly list them out
    # 2.) handle better idempotence just in case someone makes a change on the server in the ui? ( all languages )  
    $comma_seperated_update_languages = join($update_languages, ',')
    exec { 'wsus-config-update-languages':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.AllUpdateLanguagesEnabled = \$false
                    \$wsusConfiguration.AllUpdateLanguagesDssEnabled = \$false
                    \$wsusConfiguration.SetEnabledUpdateLanguages(\"${comma_seperated_update_languages}\" -split \",\")
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusServerConfig = (Get-WsusServer).GetConfiguration()
                    \$currentEnabledLanguages = \$wsusServerConfig.GetEnabledUpdateLanguages()
                    \$compareResult = Compare-Object -ReferenceObject \$currentEnabledLanguages -DifferenceObject (\"${comma_seperated_update_languages}\").Split(\",\")
                    if(\$compareResult -eq \$null)
                    {
                        # no differences
                        Exit 0
                    }
                    else
                    {
                        # differences
                        Exit 1
                    }",
      logoutput => true,
      provider  => 'powershell',
    }

    exec { 'wsus-config-update-targeting-mode':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.TargetingMode = \"${targeting_mode}\"
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$targetingMode = (Get-WsusServer).GetConfiguration().TargetingMode
                    if (\$targetingMode -eq \"${targeting_mode}\") {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }

    # Is this needed?
    # Removing default products and classifications before initial sync

    # Get WSUS Subscription and perform initial synchronization to get:
    # 1. Types of updates availabile
    # 1. Products that are available
    # 1. Languages that are available
    # exec { 'wsus-config-update-initial-synchronization':
    #   command   => "\$ErrorActionPreference = \"Stop\"
    #                 \$subscription = (Get-WsusServer).GetSubscription()
    #                 \$subscription.StartSynchronizationForCategoryOnly()
    #                 While (\$subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    #                   Write-Output \".\" -NoNewline
    #                   Start-Sleep -Seconds 5
    #                 }",
    #   unless    => "\$firstSyncResult = (Get-WsusServer).GetSubscription().GetSynchronizationHistory()[0]
    #                 if (\$firstSyncResult.Result -eq 'Succeeded') {
    #                   Exit 0
    #                 }
    #                 Exit 1",
    #   logoutput => true,
    #   timeout   => 3600,
    #   provider  => 'powershell',
    # }
    # products we care about updates for ( office, sql server, windows server 2016, etc..)
        # TODO: 
    # 1.) handle * for all languages instead of having to explicitly list them out
    # 2.) handle better idempotence just in case someone makes a change on the server in the ui? ( all products? )
    # 3.) Bomb out if the product specified by the user doesnt even exist in the possible list
    $comma_seperated_products = join($products, ',')
    exec { 'wsus-config-update-products':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusServerSubscription = (Get-WsusServer).GetSubscription()
                    \$allPossibleProducts = (Get-WsusServer).GetUpdateCategories()
                    \$coll = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection
                    \$allPossibleProducts | Where-Object { (\"${comma_seperated_products}\" -split \",\") -contains \$PSItem.Title  } | % { \$coll.Add(\$_) }        
                    \$wsusServerSubscription.SetUpdateCategories(\$coll)
                    \$wsusServerSubscription.Save()",
      unless    => "\$wsusServerSubscription = (Get-WsusServer).GetSubscription()
                    \$currentEnabledProducts = \$wsusServerSubscription.GetUpdateCategories().Title
                    if(\$currentEnabledProducts -eq \$null)
                    {
                      \$currentEnabledProducts = @('')
                    }
                    \$compareResult = Compare-Object -ReferenceObject \$currentEnabledProducts -DifferenceObject (\"${comma_seperated_products}\").Split(\",\")
                    if(\$compareResult -eq \$null)
                    {
                        # no differences
                        Exit 0
                    }
                    else
                    {
                        # differences
                        Exit 1
                    }",
      logoutput => true,
      provider  => 'powershell',
    }

    # The update classifications we care about ( critical, security, defintion.. etc )
    $comma_seperated_update_classifications = join($update_classifications, ',')
    exec { 'wsus-config-update-classifications':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusServerSubscription = (Get-WsusServer).GetSubscription()            
                    \$allPossibleUpdateClassifications = (Get-WsusServer).GetUpdateClassifications()            
                    \$coll = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection            
                    \$allPossibleUpdateClassifications | Where-Object { (\"${comma_seperated_update_classifications}\" -split \",\") -contains \$PSItem.Title  } | % { \$coll.Add(\$_) }        
                    \$wsusServerSubscription.SetUpdateClassifications(\$coll)
                    \$wsusServerSubscription.Save()",
      unless    => "\$wsusServerSubscription = (Get-WsusServer).GetSubscription()         
                    \$currentEnabledUpdateClassifications = \$wsusServerSubscription.GetUpdateClassifications().Title
                    if(\$currentEnabledUpdateClassifications -eq \$null)
                    {
                      \$currentEnabledUpdateClassifications = @('')
                    }
                    \$compareResult = Compare-Object -ReferenceObject \$currentEnabledUpdateClassifications -DifferenceObject (\"${comma_seperated_update_classifications}\").Split(\",\")
                    if(\$compareResult -eq \$null)
                    {
                        # no differences
                        Exit 0
                    }
                    else
                    {
                        # differences
                        Exit 1
                    }",
      logoutput => true,
      provider  => 'powershell',
    }

    # Host binaries on microsoft update or download them and serve them to client from the wsus server
    # HostBinariesOnMicrosoftUpdate
    exec { 'wsus-config-update-host-binaries-on-microsoft-update':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.HostBinariesOnMicrosoftUpdate=\$${host_binaries_on_microsoft_update}
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if (\$wsusConfiguration.HostBinariesOnMicrosoftUpdate -eq \$${host_binaries_on_microsoft_update}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }

        # IUpdateServerConfiguration.DownloadUpdateBinariesAsNeeded
    # Only download updates locally for approved updates and not all even if unapproved


    # suppress annoying WSUS configuration wizard when installing by automation
    exec { 'wsus-config-update-configuration-wizard-suppress':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    \$wsusConfiguration.OobeInitialized=\$true
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if (\$wsusConfiguration.OobeInitialized -eq \$true) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }

    # Time to configure synchronization schedule
    # synchronize automatically to prevent manual processes
    exec { 'wsus-config-update-synchronize-automatically':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusSubscription = (Get-WsusServer).GetSubscription()
                    \$wsusSubscription.SynchronizeAutomatically=\$${synchronize_automatically}
                    \$wsusSubscription.SynchronizeAutomaticallyTimeOfDay=[System.TimeSpan]::Parse(\"${synchronize_time_of_day}\")
                    \$wsusSubscription.NumberOfSynchronizationsPerDay=${number_of_synchronizations_per_day}
                    \$wsusSubscription.Save()",
      unless    => "\$wsusSubscription = (Get-WsusServer).GetSubscription()
                    if (\$wsusSubscription.SynchronizeAutomatically -eq \$${synchronize_automatically}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }

    # Perform full syncrhronization immediately after all configuration is done
    if ($trigger_full_synchronization_post_install) {
      exec { 'wsus-post-configuration-full-synchronization':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusConfiguration = (Get-WsusServer).GetSubscription()
                    \$wsusConfiguration.SynchronizeAutomatically=\$${synchronize_automatically}
                    \$wsusConfiguration.SynchronizeAutomaticallyTimeOfDay=[System.TimeSpan]::Parse(\"${synchronize_time_of_day}\")
                    \$wsusConfiguration.NumberOfSynchronizationsPerDay=${number_of_synchronizations_per_day}
                    \$wsusConfiguration.Save()
                    While (\$wsusConfiguration.GetUpdateServerConfigurationState() -eq 'ProcessingSave') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetSubscription()
                    if (\$wsusConfiguration.SynchronizeAutomatically -eq \$${synchronize_automatically}) {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      provider  => 'powershell',
    }
    }
}
