# Define: wsusserver::approvalrule
# Parameters:
# 
#
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
                          \$wsus.CreateInstallApprovalRule(\"${rule_name}\")",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$result = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          if(\$result.Count -eq 0) { Exit 0 } Else { Exit 1 }",
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
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          if(\$approvalRule.Enabled -ne \$${enabled}) { Exit 0 } Else { Exit 1 }",
            logoutput => true,
            provider  => 'powershell',
        }

        $semicolon_seperated_classifications = join($classifications, ';')
        exec { "update-wsus-approvalrule-classifications-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$classificationCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection -ErrorAction Stop
                          Get-WsusClassification | Select-Object -ExpandProperty Classification | Where-Object { (\"${semicolon_seperated_classifications}\" -split \";\") -contains \$PSItem.Title  } | % { \$classificationCollection.Add(\$_) }  
                          \$approvalRule.SetUpdateClassifications(\$classificationCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$currentApprovalClassifications = \$approvalRule.GetUpdateClassifications() | Select-Object -ExpandProperty Title
                          if(\$currentApprovalClassifications -eq \$null)
                          {
                            \$currentApprovalClassifications = \"\"
                          }
                          \$compareResult = Compare-Object -ReferenceObject \$currentApprovalClassifications -DifferenceObject (\"${semicolon_seperated_classifications}\").Split(\";\")
                          if(\$compareResult -eq \$null)
                          {
                            # no differences
                            Exit 1
                          } Else { Exit 0 }",
            logoutput => true,
            provider  => 'powershell',
        }

        $semicolon_seperated_products = join($products, ';')
        exec { "update-wsus-approvalrule-products-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$productCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection
                          Get-WsusProduct | Select-Object -ExpandProperty Product | Where-Object { (\"${semicolon_seperated_products}\" -split \";\") -contains \$PSItem.Title  } | % { \$productCollection.Add(\$_) }  
                          \$approvalRule.SetCategories(\$productCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$currentApprovalCategories = \$approvalRule.GetCategories() | Select-Object -ExpandProperty Title
                          if(\$currentApprovalCategories -eq \$null)
                          {
                            \$currentApprovalCategories = \"\"
                          }
                          \$compareResult = Compare-Object -ReferenceObject \$currentApprovalCategories -DifferenceObject (\"${semicolon_seperated_products}\").Split(\";\")
                          if(\$compareResult -eq \$null)
                          {
                            # no differences
                            Exit 1
                          } Else { Exit 0 }",
            logoutput => true,
            provider  => 'powershell',
        }

        $semicolon_seperated_computer_groups = join($computer_groups, ';')
        exec { "update-wsus-approvalrule-computer-groups-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$computerGroupCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
                          (Get-WsusServer).GetComputerTargetGroups() | Where-Object { (\"${semicolon_seperated_computer_groups}\" -split \";\") -contains \$PSItem.Name  } | % { \$computerGroupCollection.Add(\$_) }  
                          \$approvalRule.SetComputerTargetGroups(\$computerGroupCollection)
                          \$approvalRule.Save()",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$approvalRule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          \$currentComputerTargetGroups = \$approvalRule.GetComputerTargetGroups() | Select-Object -ExpandProperty Name
                          if(\$currentComputerTargetGroups -eq \$null)
                          {
                            \$currentComputerTargetGroups = \"\"
                          }
                          \$compareResult = Compare-Object -ReferenceObject \$currentComputerTargetGroups -DifferenceObject (\"${semicolon_seperated_computer_groups}\").Split(\";\")
                          if(\$compareResult -eq \$null)
                          {
                            # no differences
                            Exit 1
                          } { Exit 0 }",
            logoutput => true,
            provider  => 'powershell',
        }

    } else {
        exec { "delete-wsus-approvalrule-${rule_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$rule = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          (Get-WsusServer).DeleteInstallApprovalRule(\$rule.Id)",
            onlyif    => "\$ErrorActionPreference = \"Stop\"
                          \$wsus = Get-WsusServer
                          \$result = \$wsus.GetInstallApprovalRules() | Where-Object { \$PSItem.Name -eq \"${rule_name}\" }
                          if(\$result.Count -eq 1) {
                            Exit 0
                          } Else { Exit 1 }",
            logoutput => true,
            provider  => 'powershell',
        }
    }
}
