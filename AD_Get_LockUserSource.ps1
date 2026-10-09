[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

$Pdc = (Get-AdDomain).PDCEmulator
$ParamsEvn = @{
    'Computername' = $Pdc
    'LogName' = 'Security'
    'FilterXPath' = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$Username']]"
}

$Evnts = Get-WinEvent @ParamsEvn -ErrorAction SilentlyContinue

if ($Evnts) {
    $Evnts | ForEach-Object { $_.Properties[1].Value + ' ' + $_.TimeCreated }
} else {
    Write-Output "No lockout events found for user '$Username' on PDC '$Pdc'."
}
