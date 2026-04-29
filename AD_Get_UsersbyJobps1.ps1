# Import the Active Directory module (if not already imported)
Import-Module ActiveDirectory

# Define the job title to search for
$jobTitle = "*Office*"

# Fetch all users with the specified job title
$users = Get-ADUser -Filter {Title -like $jobTitle} -Property DisplayName, Title, EmailAddress, Company, Department

# Check if any users were found
if ($users.Count -eq 0) {
    Write-Output "No users found with the job title containing '$jobTitle'."
} else {
    # Sort the users by company and display name
    $sortedUsers = $users | Sort-Object Company, DisplayName
    
    # Create a table to display the sorted users
    $table = $sortedUsers | Select-Object DisplayName, Title, EmailAddress, Company, Department | Format-Table -AutoSize

    # Display the table
    $table | Out-String
}
