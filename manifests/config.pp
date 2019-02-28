# Class: wsusserver::config
#
#
class wsusserver::config(
  Array[String, 1] $update_languages,
  Array[String, 0] $products,
  Optional[Array[String]] $product_families,
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
    $sync_recipients = join($sync_notification_recipients, ', ')
    exec { 'wsus-config-sync-notification-settings':
      #Set sync to true or false
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailNotificationConfiguration.SendSyncNotification = \$${send_sync_notification}
                    #Clear recipient list
                    \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.Clear()
                    #Add all recipients
                    foreach (\$recip in \"${sync_recipients}\".split(',')) {
                       \$wsusEmailNotificationConfiguration.SyncNotificationRecipients.Add(\$recip)
                    }
                    \$wsusEmailNotificationConfiguration.Save()
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
    $status_recipients = join($status_notification_recipients, ', ')
    exec { 'wsus-config-status-report-notification-settings':
      #Set sync to true or false
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusEmailNotificationConfiguration = (Get-WsusServer).GetEmailNotificationConfiguration()
                    \$wsusEmailNotificationConfiguration.SendStatusNotification = \$${send_status_notification}
                    #Clear recipient list
                    \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.Clear()
                    #Add all recipients
                    foreach (\$recip in \"${status_recipients}\".split(',')) {
                       \$wsusEmailNotificationConfiguration.StatusNotificationRecipients.Add(\$recip)
                    }
                    \$wsusEmailNotificationConfiguration.Save()
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

    # Get WSUS Subscription and perform initial synchronization to get:
    # 1. Types of updates availabile
    # 1. Products that are available
    # 1. Languages that are available
    exec { 'wsus-config-update-initial-synchronization':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$subscription = (Get-WsusServer).GetSubscription()
                    \$subscription.StartSynchronizationForCategoryOnly()
                    While (\$subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
                      Write-Output \".\" -NoNewline
                      Start-Sleep -Seconds 5
                    }",
      unless    => "\$firstSyncResult = (Get-WsusServer).GetSubscription().GetSynchronizationHistory()[0]
                    if (\$firstSyncResult.Result -eq 'Succeeded') {
                      Exit 0
                    }
                    Exit 1",
      logoutput => true,
      timeout   => 3600,
      provider  => 'powershell',
    }

    # products and product_families we care about updates for ( office, sql server, windows server 2016, etc..)
    $comma_seperated_products = join($products, ';')
    $comma_seperated_product_families = join($product_families, ';')

    debug("Products: ${comma_seperated_products}")
    debug("Product Families: ${comma_seperated_product_families}")

    exec { 'wsus-config-update-products':
      command   => "function Invoke-WsusCategoryConfig {
                      param (
                        [String[]]\$ProductTitles,
                        [ValidateSet(\"product\", \"productfamily\")][String]\$Type,
                        [Microsoft.UpdateServices.Administration.UpdateCategoryCollection]\$NewProducts
                      )

                      # get all possible products
                      \$allPossibleProducts = (Get-WsusServer).GetUpdateCategories() | Where-Object {\$_.type -eq \$Type}

                      # if product titles is not blank, then validate supplied product titles
                      if (\$ProductTitles -ne \"\" -and \$null -ne \$ProductTitles) {
                        ForEach (\$product in \$ProductTitles) {
                          if (\$allPossibleProducts.Title -notcontains \$product) {
                            # some invalid product names have been supplied
                            # write to stderr but don't stop
                            Write-Host \"Invalid product name supplied - \$product\" -ErrorAction Continue
                            # a controlled exit with non-zero  status
                            Exit 3
                          }
                          else {
                            # product title is valid. add it to the new collection
                            [void]\$NewProducts.add( (\$allPossibleProducts | Where-Object {\$_.Title -eq \$product -and \$_.type -eq \$Type} | Select-Object -First 1) )
                          }
                        }
                      }
                      else {
                        # no product titles supplied. that's fine, but we need an empty object to compare
                        \$ProductTitles = @('')
                      }

                      # get all current synced products
                      \$currentProducts = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection

                      # add currently enabled products and product families to the collection object
                      \$wsusServerSubscription.GetUpdateCategories() | ForEach-Object {[void]\$currentProducts.add(\$_)}

                      # get products configured that match the supplied type
                      \$referenceObject = \$currentProducts | where-object {\$_.type -eq \$Type} | Select-Object -ExpandProperty Title -Unique 

                      # if none, blank array for object compare
                      if (\$null -eq \$referenceObject) { \$referenceObject = @('') }

                      # compare
                      \$productCompare = Compare-Object -ReferenceObject \$referenceObject -DifferenceObject \$ProductTitles

                      # loop throuch each difference
                      Foreach (\$difference in \$productCompare) {
                        # check it's not blank - this happens if no product titles have been supplied
                        if (\$difference.InputObject -ne \"\") {
                          if (\$difference.SideIndicator -eq \"=>\") {
                            # it's in the desired list but not configured, so it's being added
                            Write-Host \"Adding \$Type \$(\$difference.InputObject)\"
                          }
                          else {
                            # it's not in the desired list but configured, so it's being removed
                            Write-Host \"Removing \$Type \$(\$difference.InputObject)\"
                          }
                        }
                      }
                    }

                    trap {
                      # using write-host so the error goes to stdout, which is all the puppet exec resource picks up
                      Write-Host \"Unhandled exception caught:\"
                      Write-Host \$_.invocationinfo.positionmessage.ToString() # Line the error was generated on
                      Write-Host \$_.exception.ToString()                      # Error message
                      exit 165
                    }

                    \$ErrorActionPreference = \"Stop\"
                    # interpolate variables from puppet
                    \$commaSeparatedProducts = \"${comma_seperated_products}\"
                    \$commaSeparatedProductFamilies = \"${comma_seperated_product_families}\"
                    # get wsus server subscription configuration
                    \$wsusServerSubscription = (Get-WsusServer).GetSubscription()

                    \$newUpdateCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection

                    # check for valid parameters
                    if (\$commaSeparatedProducts -eq \"*\" -and \$commaSeparatedProductFamilies -ne \"\") {
                      # write to stderr but don't stop
                      Write-Host \"Cannot sync both all products (*) and a subset of product families\" -ErrorAction Continue
                      # a controlled exit with non-zero  status
                      Exit 2
                    }
                    elseif (\$commaSeparatedProducts -eq \"*\") {
                      # synchronizing all products
                      Write-Host \"Configuring WSUS to synchronize all products\"
                      # add all categories to the collection
                      (Get-WsusServer).GetUpdateCategories() | ForEach-Object {[void]\$newUpdateCollection.add(\$_)}
                    }
                    else {
                      # synchronizing only specific products and/or families

                      # products
                      if (\$commaSeparatedProducts -ne \"\" -and \$null -ne \$commaSeparatedProducts) {
                        # we've been supplied some products to sync
                        # split them back to an array
                        \$products = \$commaSeparatedProducts -split \";\"
                      }
                      else { 
                        \$products = \$null

                      }
                      if (\$commaSeparatedProductFamilies -ne \"\" -and \$null -ne \$commaSeparatedProductFamilies) {
                        # we've been supplied some product families to sync
                        # split them back to an array
                        \$productFamilies = \$commaSeparatedProductFamilies -split \";\"
                      }
                      else {
                        \$productFamilies = \$null
                      }

                      Invoke-WsusCategoryConfig -ProductTitles \$products -Type \"product\" -NewProducts \$newUpdateCollection
                      Invoke-WsusCategoryConfig -ProductTitles \$productFamilies -Type \"productfamily\" -NewProducts \$newUpdateCollection
                    }

                    # configure wsus
                    \$wsusServerSubscription.SetUpdateCategories(\$newUpdateCollection)
                    \$wsusServerSubscription.Save()",

      unless    => "trap {
                      # using write-host so the error goes to stdout, which is all the puppet exec resource picks up
                      Write-Host \"Unhandled exception caught:\"
                      Write-Host \$_.invocationinfo.positionmessage.ToString() # Line the error was generated on
                      Write-Host \$_.exception.ToString()                      # Error message
                      exit 165
                    }
                    \$ErrorActionPreference = \"Stop\"
                    # interpolate variables from puppet
                              \$commaSeparatedProducts = \"${comma_seperated_products}\"
                              \$commaSeparatedProductFamilies = \"${comma_seperated_product_families}\"
                    # get current wsus subscription config
                    \$wsusServerSubscription = (Get-WsusServer).GetSubscription()
                    if (\$commaSeparatedProducts -eq \"*\") {
                      # all products should be selected        
                      \$desired_products = ((Get-WsusServer).GetUpdateCategories() | Where-Object {\$_.type -eq \"product\"}).Title
                      \$desired_productfamilies = ((Get-WsusServer).GetUpdateCategories() | Where-Object {\$_.type -eq \"productfamily\"}).Title
                    }
                    else {
                      \$desired_products = \$commaSeparatedProducts.Split(\";\")
                      \$desired_productfamilies = \$commaSeparatedProductFamilies.Split(\";\")
                    }
                    # get current enabled product families, blank array if none
                    \$currentEnabledProductFamilies = (\$wsusServerSubscription.GetUpdateCategories() | Where-Object {\$_.type -eq \"productfamily\"}).Title
                    if (\$null -eq \$currentEnabledProductFamilies) { \$currentEnabledProductFamilies = @('') }
                    # get current enabled products, blank array if none
                    \$currentEnabledProducts = (\$wsusServerSubscription.GetUpdateCategories() | Where-Object {\$_.type -eq \"product\"}).Title
                    if (\$null -eq \$currentEnabledProducts) { \$currentEnabledProducts = @('') }
                    # compare product families
                    \$compareProductFamiliesResult = Compare-Object -ReferenceObject \$currentEnabledProductFamilies -DifferenceObject \$desired_productfamilies
                    # compare products
                    \$compareProductsResult = Compare-Object -ReferenceObject \$currentEnabledProducts -DifferenceObject \$desired_products
                    # check results
                    if (\$null -eq \$compareProductFamiliesResult -and \$null -eq \$compareProductsResult) {
                      # no differences
                      Exit 0
                    }
                    else {
                      Write-Host \"WSUS product or product family configuration does not match desired state\"
                      # differences
                      Exit 1
                    }",
      logoutput => true,
      provider  => 'powershell',
    }

    # The update classifications we care about ( critical, security, defintion.. etc )
    $comma_seperated_update_classifications = join($update_classifications, ';')
    exec { 'wsus-config-update-classifications':
      command   => "\$ErrorActionPreference = \"Stop\"
                    \$wsusServerSubscription = (Get-WsusServer).GetSubscription()            
                    \$allPossibleUpdateClassifications = (Get-WsusServer).GetUpdateClassifications()            
                    \$coll = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection            
                    \$allPossibleUpdateClassifications | Where-Object { (\"${comma_seperated_update_classifications}\" -split \";\") -contains \$PSItem.Title  } | ForEach-Object { \$coll.Add(\$_) }        
                    \$wsusServerSubscription.SetUpdateClassifications(\$coll)
                    \$wsusServerSubscription.Save()",
      unless    => "\$wsusServerSubscription = (Get-WsusServer).GetSubscription()         
                    \$currentEnabledUpdateClassifications = \$wsusServerSubscription.GetUpdateClassifications().Title
                    if(\$currentEnabledUpdateClassifications -eq \$null)
                    {
                      \$currentEnabledUpdateClassifications = @('')
                    }
                    \$compareResult = Compare-Object -ReferenceObject \$currentEnabledUpdateClassifications -DifferenceObject (\"${comma_seperated_update_classifications}\").Split(\";\")
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
