[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$JobTitle = "*Office*"
)

# Import the Active Directory module (if not already imported)
Import-Module ActiveDirectory

# Fetch all users with the specified job title
# String filter is preferred over script block for Get-ADUser
$users = Get-ADUser -Filter "Title -like '$JobTitle'" -Property DisplayName, Title, EmailAddress, Company, Department

# Check if any users were found
if (-not $users) {
    Write-Output "No users found with the job title containing '$JobTitle'."
} else {
    # Sort the users by company and display name
    $sortedUsers = $users | Sort-Object Company, DisplayName

    # Display the sorted users
    $sortedUsers | Select-Object DisplayName, Title, EmailAddress, Company, Department | Format-Table -AutoSize
}
