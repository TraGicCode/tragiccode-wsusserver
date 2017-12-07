# Define: wsusserver::computertargetgroup
# Parameters:
# 
#
define wsusserver::computertargetgroup (
    String $group_name = $title,
    Enum['present', 'absent'] $ensure = 'present',
) {
    if ($ensure == 'present') {
        exec { "create-wsus-computertargetgroup-${group_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$(Get-WsusServer).CreateComputerTargetGroup(\"${group_name}\")",
            unless    => "\$result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { \$PSItem.Name -eq \"${group_name}\" }
                          if(\$result.Count -eq 1) {
                            Exit 0
                          }
                          Exit 1",
            logoutput => true,
            provider  => 'powershell',
        }
    } else {
        exec { "delete-wsus-computertargetgroup-${group_name}":
            command   => "\$ErrorActionPreference = \"Stop\"
                          \$result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { \$PSItem.Name -eq \"${group_name}\" }
                          \$result.Delete()",
            onlyif    => "\$result = (Get-WsusServer).GetComputerTargetGroups() | Where-Object { \$PSItem.Name -eq \"${group_name}\" }
                          if(\$result.Count -eq 1) {
                            Exit 0
                          }
                          Exit 1",
            logoutput => true,
            provider  => 'powershell',
        }
    }
}