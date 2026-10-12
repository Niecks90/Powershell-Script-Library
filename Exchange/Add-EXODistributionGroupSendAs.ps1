<#
.SYNOPSIS
    Grants SendAs permission to a trustee for an Exchange Online distribution group.

.DESCRIPTION
    This script connects to Exchange Online (if not already connected) and grants the specified
    'SendAs' rights to a trustee (user or group) on a given distribution group identity.
    It then outputs the updated permissions for verification.

.PARAMETER Identity
    The email address, alias, or distinguished name of the distribution group.

.PARAMETER Trustee
    The email address, alias, or distinguished name of the user/group receiving the permission.

.EXAMPLE
    Add-EXODistributionGroupSendAs -Identity "sales-team@domain.com" -Trustee "jdoe@domain.com"

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

    [Parameter(Mandatory = $true, HelpMessage = "The identity of the trustee receiving SendAs rights.")]
    [ValidateNotNullOrEmpty()]
    [string]$Trustee
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

    if ($PSCmdlet.ShouldProcess($Identity, "Grant SendAs permission to $Trustee")) {
        Add-RecipientPermission -Identity $Identity -Trustee $Trustee -AccessRights SendAs -Confirm:$false -ErrorAction Stop

        Write-Verbose "Verifying permissions..."
        Get-RecipientPermission -Identity $Identity -Trustee $Trustee -ErrorAction Stop |
            Select-Object Trustee, AccessControlType, AccessRights
    }
} catch {
    Write-Error "An error occurred while granting RecipientPermission: $_"
}
