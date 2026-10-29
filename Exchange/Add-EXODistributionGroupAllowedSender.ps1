<#
.SYNOPSIS
    Adds allowed senders to an Exchange Online distribution group.

.DESCRIPTION
    This script connects to Exchange Online (if not already connected) and adds the specified
    users to the 'AcceptMessagesOnlyFromSendersOrMembers' property of a distribution group.
    It then outputs the updated permissions for verification.

.PARAMETER Identity
    The email address, alias, or distinguished name of the distribution group.

.PARAMETER Users
    An array of email addresses, aliases, or distinguished names of the users to add to the allowed senders list.

.EXAMPLE
    Add-EXODistributionGroupAllowedSender -Identity "list@domain.eu" -Users "user1@domain.eu","user2@domain.eu"

.OUTPUTS
    System.Object

.NOTES
    Requires the ExchangeOnlineManagement module.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The identity of the distribution group.")]
    [ValidateNotNullOrEmpty()]
    [string]$Identity,

    [Parameter(Mandatory = $true, HelpMessage = "The identities of the users to add to the allowed senders list.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$Users
)

$ErrorActionPreference = 'Stop'

try {
    # Check if module is available, but do not auto-install to avoid unexpected system changes
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Error "ExchangeOnlineManagement module is not installed. Please install it first."
        return
    }

    # Connect to Exchange Online if not connected
    if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
        Write-Verbose "Connecting to Exchange Online..."
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
    }

    if ($PSCmdlet.ShouldProcess($Identity, "Add allowed senders: $($Users -join ', ')")) {
        Set-DistributionGroup -Identity $Identity -AcceptMessagesOnlyFromSendersOrMembers @{Add=$Users} -Confirm:$false -ErrorAction Stop

        Write-Verbose "Verifying permissions..."
        Get-DistributionGroup -Identity $Identity -ErrorAction Stop |
            Select-Object -ExpandProperty AcceptMessagesOnlyFromSendersOrMembers |
            Get-Recipient -ErrorAction Stop |
            Select-Object DisplayName, PrimarySmtpAddress
    }
} catch {
    Write-Error "An error occurred while modifying the distribution group: $_"
}
