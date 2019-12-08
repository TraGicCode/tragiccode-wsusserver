# Define: wsusserver::approvalrule
# Parameters:
#
#
# Adding -Unique stops corrective action applying if duplicate rules get created by accident
define wsusserver::approvalrule (
    Array[String] $classifications, # Critical update, security update...etc
    Array[String] $products,
    Array[String] $computer_groups,
    String $rule_name = $title,
    Enum['present', 'absent'] $ensure = 'present',
    Boolean $enabled = true,
) {
    if ($ensure == 'present') {
        exec { "create-wsus-approvalrule-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          [void]\$wsus.CreateInstallApprovalRule(\"${rule_name}\")",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$result = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$result.Count -eq 0) { Exit 0 } Else { Exit 1 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }

        exec { "enable-wsus-approvalrule-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$approvalRule.Enabled = \$${enabled}
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$null -ne \$approvalRule -and \$approvalRule.Enabled -ne \$${enabled}) { Exit 0 } Else { Exit 1 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }

        $comma_seperated_classifications = join($classifications, ',')
        exec { "update-wsus-approvalrule-classifications-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$classificationCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection -ErrorAction Stop
                          Get-WsusClassification | Select-Object -ExpandProperty Classification | Where-Object { (\"${comma_seperated_classifications}\" -split \",\") -contains \$PSItem.Title  } | ForEach-Object { [void]\$classificationCollection.Add(\$_) }
                          \$approvalRule.SetUpdateClassifications(\$classificationCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$null -eq \$approvalRule) {
                              # matching rule doesn't exist
                              Exit 1
                            }
                            \$currentApprovalClassifications = \$approvalRule.GetUpdateClassifications() | Select-Object -ExpandProperty Title -Unique
                            if(\$currentApprovalClassifications -eq \$null)
                            {
                              \$currentApprovalClassifications = \"\"
                            }
                            \$compareResult = Compare-Object -ReferenceObject \$currentApprovalClassifications -DifferenceObject (\"${comma_seperated_classifications}\").Split(\",\")
                            if(\$compareResult -eq \$null)
                            {
                              # no differences
                              Exit 1
                            } Else { Exit 0 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }

        $comma_seperated_products = join($products, ',')
        exec { "update-wsus-approvalrule-products-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$productCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection
                          Get-WsusProduct | Select-Object -ExpandProperty Product | Where-Object { (\"${comma_seperated_products}\" -split \",\") -contains \$PSItem.Title  } | ForEach-Object { [void]\$productCollection.Add(\$_) }
                          \$approvalRule.SetCategories(\$productCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$null -eq \$approvalRule) {
                              # matching rule doesn't exist
                              Exit 1
                            }
                            \$currentApprovalCategories = \$approvalRule.GetCategories() | Select-Object -ExpandProperty Title -Unique
                            if(\$currentApprovalCategories -eq \$null)
                            {
                              \$currentApprovalCategories = \"\"
                            }
                            \$compareResult = Compare-Object -ReferenceObject \$currentApprovalCategories -DifferenceObject (\"${comma_seperated_products}\").Split(\",\")
                            if(\$compareResult -eq \$null)
                            {
                              # no differences
                              Exit 1
                            } Else { Exit 0 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }

        $comma_seperated_computer_groups = join($computer_groups, ',')
        exec { "update-wsus-approvalrule-computer-groups-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$computerGroupCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
                          \$wsus.GetComputerTargetGroups() | Where-Object { (\"${comma_seperated_computer_groups}\" -split \",\") -contains \$PSItem.Name  } | ForEach-Object { [void]\$computerGroupCollection.Add(\$_) }
                          \$approvalRule.SetComputerTargetGroups(\$computerGroupCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$null -eq \$approvalRule) {
                              # matching rule doesn't exist
                              Exit 1
                            }
                            \$currentComputerTargetGroups = \$approvalRule.GetComputerTargetGroups() | Select-Object -ExpandProperty Name -Unique
                            if(\$currentComputerTargetGroups -eq \$null)
                            {
                              \$currentComputerTargetGroups = \"\"
                            }
                            \$compareResult = Compare-Object -ReferenceObject \$currentComputerTargetGroups -DifferenceObject (\"${comma_seperated_computer_groups}\").Split(\",\")
                            if(\$compareResult -eq \$null)
                            {
                              # no differences
                              Exit 1
                            } Else { Exit 0 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }

    } else {
        exec { "delete-wsus-approvalrule-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$rule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$wsus.DeleteInstallApprovalRule(\$rule.Id)",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          if (Get-Command Get-WsusServer -ErrorAction SilentlyContinue) {
                            \$wsus = Get-WsusServer
                            if (\$wsus.GetConfiguration().IsReplicaServer) {Exit 1}    # Don't run on a replica
                            \$result = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                            if(\$result.Count -eq 1) {
                              Exit 0
                            } Else { Exit 1 }
                          } Else {Exit 1}",
            logoutput => true,
            provider  => 'powershell',
        }
    }
}
