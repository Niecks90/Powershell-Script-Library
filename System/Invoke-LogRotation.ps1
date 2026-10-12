<#
.SYNOPSIS
    Archives and removes old log files in a specified directory.

.DESCRIPTION
    This script searches for files with a specific extension (e.g., .log) in a target directory
    that are older than a specified number of days. It then compresses them into a ZIP archive
    and deletes the original files. It implements ShouldProcess to allow dry runs (-WhatIf).

.PARAMETER LogPath
    The directory containing the log files.

.PARAMETER DaysToKeep
    Files older than this number of days will be rotated (archived and deleted). Defaults to 30.

.PARAMETER Extension
    The file extension to target. Defaults to '*.log'.

.PARAMETER ArchivePath
    The directory to store the ZIP archives. Defaults to the same as LogPath.

.EXAMPLE
    Invoke-LogRotation -LogPath "C:\inetpub\logs\LogFiles" -DaysToKeep 15 -Extension "*.log"

.OUTPUTS
    None
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The directory containing the logs.")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$LogPath,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3650)]
    [int]$DaysToKeep = 30,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Extension = "*.log",

    [Parameter(Mandatory = $false)]
    [string]$ArchivePath
)

$ErrorActionPreference = 'Stop'

try {
    if (-not $ArchivePath) {
        $ArchivePath = $LogPath
    } elseif (-not (Test-Path $ArchivePath -PathType Container)) {
        New-Item -Path $ArchivePath -ItemType Directory -Force | Out-Null
    }

    $thresholdDate = (Get-Date).AddDays(-$DaysToKeep)

    $oldLogs = Get-ChildItem -Path $LogPath -Filter $Extension -File -ErrorAction Stop |
               Where-Object { $_.LastWriteTime -lt $thresholdDate }

    if (-not $oldLogs) {
        Write-Verbose "No files older than $DaysToKeep days found matching '$Extension' in '$LogPath'."
        return
    }

    $archiveName = "LogsArchive_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    $fullArchivePath = Join-Path -Path $ArchivePath -ChildPath $archiveName

    if ($PSCmdlet.ShouldProcess("Archive $( $oldLogs.Count ) files to $fullArchivePath", "Compress and Remove")) {
        Write-Verbose "Compressing $( $oldLogs.Count ) files into $fullArchivePath..."
        Compress-Archive -Path $oldLogs.FullName -DestinationPath $fullArchivePath -Force -ErrorAction Stop

        Write-Verbose "Removing original log files..."
        $oldLogs | Remove-Item -Force -ErrorAction Stop

        Write-Output "Successfully rotated $( $oldLogs.Count ) log files to $fullArchivePath"
    }
} catch {
    Write-Error "An error occurred during log rotation: $_"
}
