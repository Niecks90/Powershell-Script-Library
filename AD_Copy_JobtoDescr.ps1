# Import the Active Directory module
Import-Module ActiveDirectory

# Liste des OU à cibler
$OUs = @(
    "OU=Users,OU=Benelux,DC=domain,DC=fr",
    "OU=Users,OU=Czechia,DC=domain,DC=fr",
    "OU=Users,OU=External,DC=domain,DC=fr",
    "OU=Users,OU=France,DC=domain,DC=fr",
    "OU=Users,OU=Germany,DC=domain,DC=fr",
    "OU=Users,OU=Group,DC=domain,DC=fr",
    "OU=Admins,OU=Group,DC=domain,DC=fr",
    "OU=Users,OU=Italy,DC=domain,DC=fr",
    "OU=Users,OU=Poland,DC=domain,DC=fr",
    "OU=Users,OU=Portugal,DC=domain,DC=fr",
    "OU=Users,OU=Romania,DC=domain,DC=fr",
    "OU=Users,OU=Spain,DC=domain,DC=fr",
    "OU=Users,OU=United Kingdom,DC=domain,DC=fr"
)

foreach ($OU in $OUs) {
    # Récupérer tous les utilisateurs dans l'OU
    $users = Get-ADUser -Filter * -SearchBase $OU -Property DisplayName, Title, Description

    foreach ($user in $users) {
        if ($user.Title -ne $null) {
            Set-ADUser -Identity $user -Description $user.Title
            Write-Output "Updated Description for $($user.DisplayName) with Job Title: $($user.Title)"
        } else {
            Write-Output "No Job Title found for $($user.DisplayName), skipping."
        }
    }
}

Write-Output "Completed updating Description fields in specified OUs."
