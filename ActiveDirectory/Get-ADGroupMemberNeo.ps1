<#
.SYNOPSIS
    Extracts members of specific AD groups to a CSV file.

.DESCRIPTION
    This script retrieves all Active Directory groups matching a specific name pattern,
    recursively lists their user members, and exports the results to a CSV file.

.PARAMETER GroupPattern
    The wildcard pattern to match group names. Defaults to 'NEO*'.

.PARAMETER ExportPath
    The path to save the output CSV file. Defaults to '.\Group_Members_Export.csv'.

.EXAMPLE
    Get-ADGroupMemberNeo -GroupPattern "Admin*" -ExportPath "C:\reports\admins.csv"

.OUTPUTS
    None

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$GroupPattern = "NEO*",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ExportPath = ".\Group_Members_Export.csv"
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $groups = Get-ADGroup -Filter "Name -like '$GroupPattern'" -ErrorAction Stop

    if (-not $groups) {
        Write-Warning "No groups found matching pattern '$GroupPattern'."
        return
    }

    $results = foreach ($group in $groups) {
        # Using server-side filtering where possible, but recursive requires client-side filter for objectClass
        $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction Stop | Where-Object { $_.objectClass -eq 'user' }

        foreach ($user in $members) {
            [PSCustomObject]@{
                LoginName = $user.SamAccountName
                GroupName = $group.Name
            }
        }
    }

    if ($results) {
        $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
        Write-Host "Extraction completed. File created: $ExportPath"
    } else {
        Write-Host "No user members found in groups matching pattern '$GroupPattern'."
    }
} catch {
    Write-Error "An error occurred during extraction: $_"
}
