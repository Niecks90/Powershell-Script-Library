# Import du module ActiveDirectory
Import-Module ActiveDirectory

# Récupérer tous les groupes commençant par "NEO"
$neoGroups = Get-ADGroup -Filter 'Name -like "NEO*"' 

# Initialiser une liste pour stocker les résultats
$results = @()

# Parcourir chaque groupe NEO
foreach ($group in $neoGroups) {
    $members = Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.objectClass -eq 'user' }

    foreach ($user in $members) {
        $userDetails = Get-ADUser $user -Properties GivenName, Surname, Department, Title

        $results += [PSCustomObject]@{
            LoginName   = $user.SamAccountName
#            GivenName   = $userDetails.GivenName
#            Surname     = $userDetails.Surname
#            Department  = $userDetails.Department
#            Title       = $userDetails.Title
            NEOGroup    = $group.Name
        }
    }
}

# Exporter les résultats dans un fichier CSV
$results | Export-Csv -Path "C:\Version\NEO_Group_Members.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Extraction terminée. Fichier créé : NEO_Group_Members.csv"
