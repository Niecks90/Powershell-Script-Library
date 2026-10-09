# Import du module ActiveDirectory
Import-Module ActiveDirectory

# Récupérer tous les groupes commençant par "NEO"
$neoGroups = Get-ADGroup -Filter 'Name -like "NEO*"'

# Collecter les résultats dans une pipeline pour éviter de charger le tableau en mémoire avec +=
$results = foreach ($group in $neoGroups) {
    $members = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.objectClass -eq 'user' }

    foreach ($user in $members) {
        [PSCustomObject]@{
            LoginName   = $user.SamAccountName
            NEOGroup    = $group.Name
        }
    }
}

# Exporter les résultats dans un fichier CSV
$results | Export-Csv -Path ".\NEO_Group_Members.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Extraction terminée. Fichier créé : NEO_Group_Members.csv"
