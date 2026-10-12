<#
.SYNOPSIS
    Exports detailed information about AD users from specified OUs to a CSV file.

.DESCRIPTION
    This script iterates through a provided list of Organizational Units (OUs), retrieves
    detailed properties for all user accounts within them, formats specific fields (like Manager name),
    and exports the aggregated data to a timestamped CSV file.

.PARAMETER SearchBase
    An array of Organizational Units (OUs) to search for users.

.PARAMETER ExportDirectory
    The directory where the CSV file should be saved. Defaults to the current directory.

.EXAMPLE
    Export-ADUserReport -SearchBase "OU=Users,OU=France,DC=domain,DC=fr" -ExportDirectory "C:\reports"

.OUTPUTS
    None

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the OUs to search for users.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$SearchBase,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ExportDirectory = "."
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

$LogDate = Get-Date -Format yyyyMMddHHmm
$Csvfile = Join-Path -Path $ExportDirectory -ChildPath "AllADUsers_$LogDate.csv"

$props = @(
    "GivenName", "Surname", "DisplayName", "SamAccountName", "UserPrincipalName",
    "Country", "Title", "Department", "Company", "Manager", "Description",
    "Office", "telephoneNumber", "Mail", "mobile", "Enabled", "lastlogondate"
)

try {
    $AllADUsers = foreach ($DN in $SearchBase) {
        try {
            Get-ADUser -SearchBase $DN -Filter * -Properties $props -ErrorAction Stop
        } catch {
            Write-Warning "Could not search DN: $DN. Reason: $_"
        }
    }

    if (-not $AllADUsers) {
        Write-Warning "No users found in the specified OUs."
        return
    }

    $AllADUsers | Sort-Object Name | Select-Object `
        @{Label = "First name"; Expression = { $_.GivenName } },
        @{Label = "Last name"; Expression = { $_.Surname } },
        @{Label = "Display name"; Expression = { $_.DisplayName } },
        @{Label = "User logon name"; Expression = { $_.SamAccountName } },
        @{Label = "User principal name"; Expression = { $_.UserPrincipalName } },
        @{Label = "Country/region"; Expression = { $_.Country } },
        @{Label = "Job Title"; Expression = { $_.Title } },
        @{Label = "Department"; Expression = { $_.Department } },
        @{Label = "Company"; Expression = { $_.Company } },
        @{Label = "Manager"; Expression = {
            if ($_.Manager) {
                if ($_.Manager -match '^CN=(?<Name>(?:[^,\\]|\\.)+)') {
                    $Matches.Name.Replace('\', '')
                } else {
                    $_.Manager
                }
            }
        }},
        @{Label = "Description"; Expression = { $_.Description } },
        @{Label = "Office"; Expression = { $_.Office } },
        @{Label = "Telephone number"; Expression = { $_.telephoneNumber } },
        @{Label = "E-mail"; Expression = { $_.Mail } },
        @{Label = "Mobile"; Expression = { $_.mobile } },
        @{Label = "Account status"; Expression = { if ($_.Enabled) { 'Enabled' } else { 'Disabled' } } },
        @{Label = "Last logon date"; Expression = { $_.lastlogondate } } |
        Export-Csv -Encoding UTF8 -Path $Csvfile -NoTypeInformation -ErrorAction Stop

    Write-Output "Exported to $Csvfile"
} catch {
    Write-Error "An error occurred during the export process: $_"
}
