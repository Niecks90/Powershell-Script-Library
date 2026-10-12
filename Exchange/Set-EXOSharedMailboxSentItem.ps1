<#
.SYNOPSIS
    Enables copying of sent items for SendAs operations on an Exchange Online shared mailbox.

.DESCRIPTION
    This script connects to Exchange Online using the provided Admin UPN (if not already connected)
    and configures the specified shared mailbox to copy items sent on its behalf (SendAs) to its own Sent Items folder.

.PARAMETER SharedMailbox
    The email address or alias of the shared mailbox to configure.

.PARAMETER AdminUPN
    The User Principal Name (UPN) of the administrator account to use for connection.

.EXAMPLE
    Set-EXOSharedMailboxSentItem -SharedMailbox "info@domain.com" -AdminUPN "admin@domain.com"

.OUTPUTS
    None

.NOTES
    Requires the ExchangeOnlineManagement module.
    It is recommended to have the module pre-installed, though this script will attempt to install it for the CurrentUser if missing.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The identity of the shared mailbox.")]
    [ValidateNotNullOrEmpty()]
    [string]$SharedMailbox,

    [Parameter(Mandatory = $true, HelpMessage = "The UPN of the admin account used to connect.")]
    [ValidateNotNullOrEmpty()]
    [string]$AdminUPN
)

$ErrorActionPreference = 'Stop'

try {
    # Attempt to install module if missing (scoped to CurrentUser to minimize system impact)
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Verbose "ExchangeOnlineManagement module not found. Attempting to install for CurrentUser..."
        Install-Module ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
    }

    # Connect to Exchange online if not connected
    if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
        Write-Verbose "Connecting to Exchange Online as $AdminUPN..."
        Connect-ExchangeOnline -UserPrincipalName $AdminUPN -ShowBanner:$false -ErrorAction Stop
    }

    if ($PSCmdlet.ShouldProcess($SharedMailbox, "Enable MessageCopyForSentAsEnabled")) {
        Set-Mailbox -Identity $SharedMailbox -MessageCopyForSentAsEnabled $true -ErrorAction Stop
        Write-Output "Successfully updated MessageCopyForSentAsEnabled to `$true for $SharedMailbox"
    }
} catch {
    Write-Error "An error occurred while updating the Shared Mailbox setting: $_"
}
