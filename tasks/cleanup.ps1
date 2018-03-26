[CmdletBinding()]
Param(
    [Boolean]
    $CleanupObsoleteComputers,
    [Boolean]
    $CleanupObsoleteUpdates,
    [Boolean]
    $CleanupUnneededContentFiles,
    [Boolean]
    $CompressUpdates,
    [Boolean]
    $DeclineExpiredUpdates,
    [Boolean]
    $DeclineSupersededUpdates
)
$cleanup_report = Invoke-WsusServerCleanup @PSBoundParameters
$_cleanup_report = @{}
ForEach($operation_result in $cleanup_report)
{
    $parts = $operation_result.Split(':')
    if ($_cleanup_report.ContainsKey($parts[0]))
    {
        $_cleanup_report[$parts[0]] += [int]$parts[1]
    }
    else
    {
        $_cleanup_report += @{
            $parts[0] = [int]$parts[1]
        }
    }
}

ConvertTo-Json -InputObject $_cleanup_report -Compress