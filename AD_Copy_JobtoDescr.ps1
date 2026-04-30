# Import the Active Directory module
Import-Module ActiveDirectory

# List of target OUs
$OUs = @(
    "OU=Users,OU=France,DC=domain,DC=fr",
    "OU=Users,OU=Spain,DC=domain,DC=fr",
    "OU=Users,OU=United Kingdom,DC=domain,DC=fr"
)

foreach ($OU in $OUs) {
    # Retrieve all users in the OU
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
