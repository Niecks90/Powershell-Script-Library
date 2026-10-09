[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Identity,

    [Parameter(Mandatory=$true)]
    [string]$Trustee
)

try {
    # Connexion a Exchange Online si non connecté
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        Connect-ExchangeOnline
    }

    # Ajouter le droits sur la liste de distrib
    Add-RecipientPermission -Identity $Identity -Trustee $Trustee -AccessRights SendAs -Confirm:$false

    # Verifier les droits sur la liste
    Get-RecipientPermission -Identity $Identity | Select-Object Trustee, AccessControlType, AccessRights
} catch {
    Write-Error "Failed to add RecipientPermission: $_"
}
