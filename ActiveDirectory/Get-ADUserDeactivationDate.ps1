<#
.SYNOPSIS
    Retrieves the date when an AD user account was last changed.

.DESCRIPTION
    This script retrieves the 'WhenChanged' attribute for a specified Active Directory user.
    This can be used to infer when an account was disabled or otherwise modified.

.PARAMETER Username
    The sAMAccountName of the user.

.EXAMPLE
    Get-ADUserDeactivationDate -Username "jdoe"

.OUTPUTS
    System.String

.NOTES
    Requires the ActiveDirectory module. Note that 'WhenChanged' reflects the last time ANY attribute
    was modified, which might not always perfectly align with the exact moment of deactivation.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the sAMAccountName of the user.")]
    [ValidateNotNullOrEmpty()]
    [string]$Username
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $User = Get-ADUser -Identity $Username -Properties WhenChanged -ErrorAction Stop
    $WhenChanged = $User.WhenChanged

    Write-Output "The account '$Username' was last changed (potentially deactivated) on: $WhenChanged"
} catch {
    Write-Error "Account '$Username' not found in Active Directory or an error occurred: $_"
}
