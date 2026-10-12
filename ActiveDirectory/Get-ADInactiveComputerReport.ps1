<#
.SYNOPSIS
    Finds computer accounts in Active Directory that have been inactive for a specified number of days.

.DESCRIPTION
    This script queries Active Directory for computer accounts where the LastLogonTimeStamp
    is older than the specified threshold. This is useful for identifying stale accounts
    for cleanup.

.PARAMETER DaysInactive
    The threshold in days. Computers inactive for longer than this will be reported. Defaults to 90.

.PARAMETER SearchBase
    An optional Organizational Unit (OU) to limit the search scope.

.EXAMPLE
    Get-ADInactiveComputerReport -DaysInactive 120

.OUTPUTS
    PSCustomObject

.NOTES
    Requires the ActiveDirectory module. LastLogonTimeStamp is replicated but has a delay (typically 9-14 days),
    so this is best used for thresholds of 30+ days.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3650)]
    [int]$DaysInactive = 90,

    [Parameter(Mandatory = $false)]
    [string]$SearchBase
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $thresholdDate = (Get-Date).AddDays(-$DaysInactive)
    $thresholdFileTime = $thresholdDate.ToFileTime()

    # Build params dynamically to optionally include SearchBase
    $getADParams = @{
        Filter = "LastLogonTimeStamp -lt $thresholdFileTime -and Enabled -eq `$true"
        Properties = @("Name", "OperatingSystem", "LastLogonTimeStamp", "DistinguishedName")
    }

    if (-not [string]::IsNullOrEmpty($SearchBase)) {
        $getADParams.Add('SearchBase', $SearchBase)
    }

    $inactiveComputers = Get-ADComputer @getADParams -ErrorAction Stop

    if ($inactiveComputers) {
        $inactiveComputers | Select-Object `
            Name,
            OperatingSystem,
            @{Name = "LastLogonDate"; Expression = { [datetime]::FromFileTime($_.LastLogonTimeStamp) }},
            @{Name = "DaysInactive"; Expression = { ((Get-Date) - [datetime]::FromFileTime($_.LastLogonTimeStamp)).Days }},
            DistinguishedName |
            Sort-Object DaysInactive -Descending
    } else {
        Write-Verbose "No active computer accounts found that have been inactive for more than $DaysInactive days."
    }
} catch {
    Write-Error "An error occurred while querying inactive computers: $_"
}
