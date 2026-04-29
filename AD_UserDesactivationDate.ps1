# Replace 'username' with the username of the AD account you want to check
$Username = "username"

# Get the AD user object
$User = Get-ADUser -Identity $Username

if ($User) {
    $WhenChanged = $User.WhenChanged
    Write-Host "The account '$Username' was last changed (deactivated) on: $WhenChanged"
} else {
    Write-Host "Account '$Username' not found in Active Directory."
}