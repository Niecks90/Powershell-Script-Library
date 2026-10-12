<#
.SYNOPSIS
    Retrieves an Active Directory object using its ObjectGUID.

.DESCRIPTION
    This script takes a GUID string, validates its format, and queries Active Directory
    to find the corresponding object. It outputs the Name and DistinguishedName of the found object.

.PARAMETER Guid
    The string representation of the Active Directory ObjectGUID.

.EXAMPLE
    Get-ADObjectByGuid -Guid "12345678-1234-1234-1234-123456789012"

.OUTPUTS
    System.String

.NOTES
    Requires the ActiveDirectory module.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the GUID of the AD object.")]
    [ValidateNotNullOrEmpty()]
    [string]$Guid
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to import ActiveDirectory module. Is RSAT installed?"
    return
}

try {
    $parsedGuid = [guid]::Parse($Guid)
} catch {
    Write-Error "Invalid GUID format provided: $Guid"
    return
}

try {
    $adObject = Get-ADObject -Identity $parsedGuid -ErrorAction Stop

    Write-Output "AD Object Found:"
    Write-Output "Name : $($adObject.Name)"
    Write-Output "DistinguishedName : $($adObject.DistinguishedName)"
} catch {
    Write-Warning "No AD object found with GUID : $Guid"
}
