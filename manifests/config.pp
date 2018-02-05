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
  Boolean $use_proxy                                 = $wsusserver::params::use_proxy,
  Hash $proxy_settings                               = $wsusserver::params::proxy_settings,
  Enum['Server', 'Client'] $targeting_mode           = $wsusserver::params::targeting_mode,
  Boolean $host_binaries_on_microsoft_update         = $wsusserver::params::host_binaries_on_microsoft_update,
  Boolean $synchronize_automatically                 = $wsusserver::params::synchronize_automatically,
  String $synchronize_time_of_day                    = $wsusserver::params::synchronize_time_of_day,
  Integer $number_of_synchronizations_per_day        = $wsusserver::params::number_of_synchronizations_per_day,
  Boolean $trigger_full_synchronization_post_install = $wsusserver::params::trigger_full_synchronization_post_install,
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

    $_proxy_settings = merge($wsusserver::params::proxy_settings_defaults, $proxy_settings)

    exec { 'wsus-config-proxy-settings':
      command   => "",
      unless    => "\$wsusConfiguration = (Get-WsusServer).GetConfiguration()
                    if (\$wsusConfiguration.UseProxy -eq \$${use_proxy}) {
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
