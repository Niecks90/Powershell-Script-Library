<#
.SYNOPSIS
    Identifies certificates in the Local Machine store that are expiring soon.

.DESCRIPTION
    This script scans the LocalMachine Certificate store (specifically the 'My' store by default)
    to find certificates that will expire within a specified number of days.
    It helps administrators proactively manage SSL/TLS and client certificates before they cause outages.

.PARAMETER DaysToExpiration
    The threshold in days. Certificates expiring within this many days will be reported. Defaults to 30.

.PARAMETER StoreName
    The specific certificate store to check. Defaults to 'My' (Personal).

.EXAMPLE
    Get-ExpiringCertificate -DaysToExpiration 60 -StoreName "Root"

.OUTPUTS
    PSCustomObject
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3650)]
    [int]$DaysToExpiration = 30,

    [Parameter(Mandatory = $false)]
    [ValidateSet('My', 'Root', 'Trust', 'CA', 'WebHosting')]
    [string]$StoreName = "My"
)

$ErrorActionPreference = 'Stop'

try {
    $thresholdDate = (Get-Date).AddDays($DaysToExpiration)
    $storePath = "Cert:\LocalMachine\$StoreName"

    if (-not (Test-Path $storePath)) {
        Write-Error "Certificate store path not found: $storePath"
        return
    }

    $certs = Get-ChildItem -Path $storePath -ExpiringInDays $DaysToExpiration -ErrorAction SilentlyContinue |
             Where-Object { $_.NotAfter -lt $thresholdDate }

    if ($certs) {
        $certs | Select-Object `
            @{Name = "Subject"; Expression = { $_.Subject }},
            @{Name = "Issuer"; Expression = { $_.Issuer }},
            @{Name = "Thumbprint"; Expression = { $_.Thumbprint }},
            @{Name = "ExpirationDate"; Expression = { $_.NotAfter }},
            @{Name = "DaysRemaining"; Expression = { ($_.NotAfter - (Get-Date)).Days }} |
            Sort-Object DaysRemaining
    } else {
        Write-Verbose "No certificates found in $storePath expiring within $DaysToExpiration days."
    }
} catch {
    Write-Error "An error occurred while checking certificates: $_"
}
