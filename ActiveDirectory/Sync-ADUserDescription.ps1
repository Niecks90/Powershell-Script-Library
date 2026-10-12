<#
.SYNOPSIS
    Synchronizes the Description field of AD users with their Job Title.

.DESCRIPTION
    This script retrieves all users in specified Organizational Units (OUs) who have a Title set.
    It then compares the Title with the Description field. If they are different, it updates
    the Description to match the Title.

.PARAMETER SearchBase
    An array of Organizational Units (OUs) to search for users.

.EXAMPLE
    Sync-ADUserDescription -SearchBase "OU=Users,OU=France,DC=domain,DC=fr", "OU=Users,OU=Spain,DC=domain,DC=fr"

.OUTPUTS
    None

.NOTES
    Requires the ActiveDirectory module.
    Needs permission to update the user accounts.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the OUs to search for users.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$SearchBase
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

foreach ($OU in $SearchBase) {
    try {
        # Retrieve all users in the OU who have a Title
        $users = Get-ADUser -Filter "Title -like '*'" -SearchBase $OU -Property DisplayName, Title, Description -ErrorAction Stop

        foreach ($user in $users) {
            if ($user.Description -ne $user.Title) {
                if ($PSCmdlet.ShouldProcess($user.DistinguishedName, "Set Description to '$($user.Title)'")) {
                    try {
                        Set-ADUser -Identity $user -Description $user.Title -ErrorAction Stop
                        Write-Verbose "Updated Description for $($user.DisplayName) with Job Title: $($user.Title)"
                    } catch {
                        Write-Warning "Failed to update $($user.DisplayName): $_"
                    }
                }
            } else {
                Write-Verbose "Description already matches Job Title for $($user.DisplayName), skipping."
            }
        }
    } catch {
        Write-Warning "Failed to process OU $OU : $_"
    }
}

Write-Verbose "Completed updating Description fields in specified OUs."
