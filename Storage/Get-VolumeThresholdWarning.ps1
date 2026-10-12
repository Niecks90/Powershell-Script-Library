<#
.SYNOPSIS
    Reports logical volumes that have fallen below a specific free space threshold.

.DESCRIPTION
    This script queries the Win32_LogicalDisk WMI/CIM class to evaluate local disk volumes.
    It calculates the percentage of free space and returns only the volumes that have less
    free space than the specified percentage threshold.

.PARAMETER MinimumFreePercentage
    The threshold percentage. Disks with free space below this value will be reported. Defaults to 15.

.EXAMPLE
    Get-VolumeThresholdWarning -MinimumFreePercentage 20

.OUTPUTS
    PSCustomObject
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 99)]
    [int]$MinimumFreePercentage = 15
)

$ErrorActionPreference = 'Stop'

try {
    # DriveType 3 = Local Fixed Disk
    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop

    $warnings = foreach ($disk in $disks) {
        if ($disk.Size -gt 0) {
            $freePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)

            if ($freePercent -lt $MinimumFreePercentage) {
                [PSCustomObject]@{
                    DriveLetter   = $disk.DeviceID
                    VolumeName    = $disk.VolumeName
                    TotalSizeGB   = [math]::Round($disk.Size / 1GB, 2)
                    FreeSpaceGB   = [math]::Round($disk.FreeSpace / 1GB, 2)
                    FreePercent   = $freePercent
                    Threshold     = $MinimumFreePercentage
                }
            }
        }
    }

    if ($warnings) {
        $warnings | Sort-Object FreePercent
    } else {
        Write-Verbose "All logical volumes have free space above the $MinimumFreePercentage% threshold."
    }
} catch {
    Write-Error "An error occurred while checking volume thresholds: $_"
}
