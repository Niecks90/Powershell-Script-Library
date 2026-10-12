<#
.SYNOPSIS
    Retrieves the source of a user account lockout from the PDC Emulator.

.DESCRIPTION
    This script queries the Primary Domain Controller (PDC) Emulator's Security event log
    for Event ID 4740 (A user account was locked out) associated with a specific username.
    It outputs the caller machine name and timestamp of the lockout events.

.PARAMETER Username
    The sAMAccountName of the locked out user.

.EXAMPLE
    Get-ADUserLockoutSource -Username "jdoe"

.OUTPUTS
    System.String

.NOTES
    Requires the ActiveDirectory module. Must be run with permissions to read the Security log on the PDC.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the username to check for lockout events.")]
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
    $Pdc = (Get-ADDomain -ErrorAction Stop).PDCEmulator

    if (-not $Pdc) {
        Write-Error "Could not determine the PDC Emulator for the domain."
        return
    }

    $ParamsEvn = @{
        'Computername' = $Pdc
        'LogName'      = 'Security'
        'FilterXPath'  = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$Username']]"
    }

    $Evnts = Get-WinEvent @ParamsEvn -ErrorAction SilentlyContinue

    if ($Evnts) {
        $Evnts | ForEach-Object {
            $caller = $_.Properties[1].Value
            $time = $_.TimeCreated
            "Caller Machine: $caller at $time"
        }
    } else {
        Write-Output "No lockout events found for user '$Username' on PDC '$Pdc'."
    }
} catch {
    Write-Error "An error occurred while checking lockout events: $_"
}
