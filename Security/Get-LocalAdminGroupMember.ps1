<#
.SYNOPSIS
    Audits the members of the local Administrators group.

.DESCRIPTION
    This script retrieves all members of the local 'Administrators' group on the machine.
    It returns a customized object containing the principal name, class (User/Group),
    and sid to help baseline and audit privileged access.

.EXAMPLE
    Get-LocalAdminGroupMember

.OUTPUTS
    PSCustomObject
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'

try {
    # We attempt to find the Administrators group by its well-known SID to support localized OS languages
    $adminGroupSid = "S-1-5-32-544"
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID -eq $adminGroupSid }

    if (-not $adminGroup) {
        Write-Error "Could not find the local Administrators group (SID: $adminGroupSid)."
        return
    }

    $members = Get-LocalGroupMember -Group $adminGroup -ErrorAction Stop

    if ($members) {
        $members | Select-Object `
            @{Name = "Principal"; Expression = { $_.Name }},
            @{Name = "PrincipalSource"; Expression = { $_.PrincipalSource }},
            @{Name = "ObjectClass"; Expression = { $_.ObjectClass }},
            @{Name = "SID"; Expression = { $_.SID }} |
            Sort-Object PrincipalSource, Principal
    } else {
        Write-Verbose "The local Administrators group is empty (highly unusual)."
    }
} catch {
    Write-Error "An error occurred while retrieving local administrators: $_"
}
