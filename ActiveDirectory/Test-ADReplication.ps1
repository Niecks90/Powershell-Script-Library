<#
.SYNOPSIS
    Tests Active Directory replication health for a specified domain controller.

.DESCRIPTION
    This script retrieves the replication partner metadata for a specified Domain Controller
    to identify replication failures or stale replication links.

.PARAMETER Server
    The target Domain Controller to check. Defaults to the local computer if run on a DC.

.EXAMPLE
    Test-ADReplication -Server "DC01"

.OUTPUTS
    PSCustomObject

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Server = $env:COMPUTERNAME
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $replicationInfo = Get-ADReplicationPartnerMetadata -Target $Server -ErrorAction Stop

    if ($replicationInfo) {
        $replicationInfo | Select-Object `
            @{Name = "Partner"; Expression = { $_.Partner }},
            @{Name = "Partition"; Expression = { $_.Partition }},
            @{Name = "LastReplicationAttempt"; Expression = { $_.LastReplicationAttempt }},
            @{Name = "LastReplicationSuccess"; Expression = { $_.LastReplicationSuccess }},
            @{Name = "ConsecutiveFailureCount"; Expression = { $_.ConsecutiveFailureCount }} |
            Sort-Object ConsecutiveFailureCount -Descending
    } else {
        Write-Verbose "No replication partner metadata found for $Server."
    }
} catch {
    Write-Error "An error occurred while testing AD replication: $_"
}
