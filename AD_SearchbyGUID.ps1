[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Guid
)

# Convert string to guid to validate the format
try {
    $parsedGuid = [guid]::Parse($Guid)
} catch {
    Write-Error "Invalid GUID format: $Guid"
    return
}

try {
    # Rechercher l'objet AD correspondant à ce GUID
    $adObject = Get-ADObject -Identity $parsedGuid -ErrorAction Stop

    Write-Host "Objet AD trouvé :"
    Write-Host "Nom : $($adObject.Name)"
    Write-Host "DistinguishedName : $($adObject.DistinguishedName)"
} catch {
    Write-Host "Aucun objet AD trouvé avec ce GUID : $Guid"
}
