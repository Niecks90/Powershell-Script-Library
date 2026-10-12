<#
.SYNOPSIS
    Tests the health and status of specific services on remote computers.

.DESCRIPTION
    This script queries one or more remote computers to check the status of specified services.
    It returns a custom object detailing the computer name, service name, status, and start type.
    It uses Invoke-Command for efficient parallel querying where possible.

.PARAMETER ComputerName
    An array of computer names to query.

.PARAMETER ServiceName
    An array of service names to check (e.g., 'wuauserv', 'spooler').

.EXAMPLE
    Test-RemoteServiceHealth -ComputerName "Server01", "Server02" -ServiceName "Spooler", "LanmanServer"

.OUTPUTS
    PSCustomObject

.NOTES
    Requires WinRM/PSRemoting to be enabled on target machines.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify target computer names.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName,

    [Parameter(Mandatory = $true, HelpMessage = "Specify the services to check.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$ServiceName
)

$ErrorActionPreference = 'Stop'

try {
    # Using Invoke-Command for parallel execution and better remoting support
    $results = Invoke-Command -ComputerName $ComputerName -ArgumentList (,$ServiceName) -ErrorAction SilentlyContinue -ScriptBlock {
        param($services)
        foreach ($service in $services) {
            try {
                $svc = Get-Service -Name $service -ErrorAction Stop
                [PSCustomObject]@{
                    ComputerName = $env:COMPUTERNAME
                    ServiceName  = $svc.Name
                    DisplayName  = $svc.DisplayName
                    Status       = $svc.Status
                    StartType    = $svc.StartType
                }
            } catch {
                [PSCustomObject]@{
                    ComputerName = $env:COMPUTERNAME
                    ServiceName  = $service
                    DisplayName  = "N/A"
                    Status       = "Not Found or Access Denied"
                    StartType    = "N/A"
                }
            }
        }
    }

    if ($results) {
        $results | Select-Object ComputerName, ServiceName, DisplayName, Status, StartType | Sort-Object ComputerName, ServiceName
    }
} catch {
    Write-Error "An error occurred during remote execution: $_"
}
