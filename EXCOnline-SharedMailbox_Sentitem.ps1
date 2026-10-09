[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$SharedMailbox,

    [Parameter(Mandatory=$true)]
    [string]$AdminUPN
)

try {
    ##Get the Exchange module
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Install-Module ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
    }

    ##Connection to Exchange online
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        Connect-ExchangeOnline -UserPrincipalName $AdminUPN
    }

    ##Change the mailbox setting
    Set-Mailbox -Identity $SharedMailbox -MessageCopyForSentAsEnabled $true
    Write-Output "Successfully updated MessageCopyForSentAsEnabled for $SharedMailbox"
} catch {
    Write-Error "Failed to update Shared Mailbox setting: $_"
}
