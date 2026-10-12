<#
.SYNOPSIS
    Retrieves a list of all unique departments from Active Directory users.

.DESCRIPTION
    This script queries Active Directory for all user accounts that have a value
    populated in the Department attribute, extracts the department names, and returns
    a sorted, deduplicated list.

.EXAMPLE
    Get-ADUserDepartment

.OUTPUTS
    System.String

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    # Retrieve all unique departments for users
    Get-ADUser -Filter "Department -like '*'" -Properties Department -ErrorAction Stop |
        Select-Object -ExpandProperty Department |
        Sort-Object -Unique
} catch {
    Write-Error "Failed to retrieve user departments: $_"
}
