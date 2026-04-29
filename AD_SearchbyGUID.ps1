# Le GUID que vous souhaitez rechercher (remplacez ce GUID par le vôtre)
$guid = "0e272e1h-0589-450a-b856-ef4c605db992"  # Exemple : "f1234567-89ab-cdef-0123-456789abcdef"

# Conversion du GUID en format compatible avec Active Directory
$guidBytes = [GUID]::Parse($guid).ToByteArray()

# Rechercher l'objet AD correspondant à ce GUID
$user = Get-ADObject -Filter { ObjectGuid -eq $guidBytes }

# Vérifier si un utilisateur a été trouvé
if ($user) {
    Write-Host "Objet AD trouvé :"
    Write-Host "Nom : $($user.Name)"
    Write-Host "DistinguishedName : $($user.DistinguishedName)"
} else {
    Write-Host "Aucun objet AD trouvé avec ce GUID : $guid"
}


