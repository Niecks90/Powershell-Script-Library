# Import the Active Directory module
Import-Module ActiveDirectory

# List of target OUs
$OUs = @(
    "OU=Users,OU=France,DC=domain,DC=fr",
    "OU=Users,OU=Spain,DC=domain,DC=fr",
    "OU=Users,OU=United Kingdom,DC=domain,DC=fr"
)

foreach ($OU in $OUs) {
    try {
        # Retrieve all users in the OU who have a Title
        $users = Get-ADUser -Filter "Title -like '*'" -SearchBase $OU -Property DisplayName, Title, Description

        foreach ($user in $users) {
            if ($user.Description -ne $user.Title) {
                try {
                    Set-ADUser -Identity $user -Description $user.Title
                    Write-Output "Updated Description for $($user.DisplayName) with Job Title: $($user.Title)"
                } catch {
                    Write-Error "Failed to update $($user.DisplayName): $_"
                }
            } else {
                Write-Output "Description already matches Job Title for $($user.DisplayName), skipping."
            }
        }
    } catch {
        Write-Error "Failed to process OU $OU : $_"
    }
}

Write-Output "Completed updating Description fields in specified OUs."
