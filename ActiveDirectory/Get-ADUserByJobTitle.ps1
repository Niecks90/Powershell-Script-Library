<#
.SYNOPSIS
    Retrieves Active Directory users based on their job title.

.DESCRIPTION
    This script queries Active Directory for users matching a specific Job Title (Title attribute)
    and returns a formatted table containing their Display Name, Title, Email Address, Company, and Department.
    The output is sorted by Company, then Display Name.

.PARAMETER JobTitle
    The string or wildcard pattern to match against the user's Title attribute. Defaults to '*Office*'.

.EXAMPLE
    Get-ADUserByJobTitle -JobTitle "*Engineer*"

.OUTPUTS
    System.Object

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Specify the job title or pattern to search for.")]
    [ValidateNotNullOrEmpty()]
    [string]$JobTitle = "*Office*"
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $users = Get-ADUser -Filter "Title -like '$JobTitle'" -Property DisplayName, Title, EmailAddress, Company, Department -ErrorAction Stop

    if (-not $users) {
        Write-Warning "No users found with the job title containing '$JobTitle'."
    } else {
        $users | Sort-Object Company, DisplayName | Select-Object DisplayName, Title, EmailAddress, Company, Department | Format-Table -AutoSize
    }
} catch {
    Write-Error "An error occurred while retrieving users: $_"
}
